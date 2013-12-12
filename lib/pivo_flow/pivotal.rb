# -*- encoding : utf-8 -*-
module PivoFlow
  class Pivotal < Base
    def run
      @story_id_file_name = ".pivotal_story_id"
      @story_id_tmp_path = File.join(@current_dir, "/tmp")
      @story_id_file_path = File.join(@story_id_tmp_path, @story_id_file_name)

      PivotalTracker::Client.token = @options["api-token"]
      PivotalTracker::Client.use_ssl = true
    end

    def ensure_project(&block)
      begin
        @options[:project] ||= PivotalTracker::Project.find(@options["project-id"])
        block.call
      rescue Exception => e
        message = "Pivotal Tracker: #{e.message}\n" +
        "[TIPS] It means that your configuration is wrong. You can reset your settings by running:\n\tpf reconfig"
        raise PivoFlow::Errors::UnsuccessfulPivotalConnection, message
      end
    end

    def user_stories
      project_stories.select{ |story| story.owned_by == user_name }
    end

    def project_stories
      @options[:stories] ||= fetch_stories
    end

    def other_users_stories
      project_stories.select{ |story| story.owned_by != user_name }
    end

    def unasigned_stories
      project_stories.select{ |story| story.owned_by == nil }
    end

    def finished_stories
      fetch_stories(10, "finished").select{ |story| story.owned_by == user_name }
    end

    def current_story force = false
      if (@options[:current_story] && !force)
        @options[:current_story]
      else
        @options[:current_story] = user_stories.count.zero? ? nil : user_stories.first
      end
    end

    def list_stories_to_output stories, activity="start"
      if (stories.nil? || stories.empty?)
        puts "No stories to show"
        return 1
      end

      HighLine.new.choose do |menu|
        menu.header = "\n--- STORIES FROM PIVOTAL TRACKER ---\nWhich one would you like to #{activity}?   "
        menu.prompt = "story no.? "
        menu.select_by = :index
        stories.each do |story|
          menu.choice(story_string(story).fix_encoding) { |answer| show_story(answer.match(/\[#(?<id>\d+)\]/)[:id])}
        end
        menu.choice("Show all") { show_stories(100) }
      end
    end

    def deliver
      list_stories_to_output finished_stories, "deliver"
    end

    def show_story story_id
      story = find_story(story_id)
      show_info story
      ask_for = story.current_state == "finished" ? "deliver" : "start"
      proceed = ask_question "Do you want to #{ask_for} this story?"
      accepted_answers = %w[yes y sure ofc jup yep yup ja tak]
      if accepted_answers.include?(proceed.downcase)
        story.current_state == "finished" ? deliver_story(story_id) : pick_up_story(story_id)
      else
        show_stories
      end
    end

    def show_info story=nil
      story = story || current_story
      if story.nil?
        puts "No story, no worry..."
        return 1
      end
      puts story_string(story, true)
      puts "\n[TASKS]"
      story.tasks.all.count.zero? ? puts("        no tasks") : print_tasks(story.tasks.all)
      puts "\n[NOTES]"
      story_notes(story).count.zero? ? puts("        no notes") : print_notes(story_notes(story))
    end

    def find_story story_id
      story = project_stories.find { |p| p.id == story_id.to_i }
      story.nil? ? @options[:project].stories.find(story_id) : story
    end

    def story_notes story, exclude_commits=true
      return story.notes.all unless exclude_commits
      story.notes.all.select { |n| n.text !~ /Commit by/ }
    end

    def story_string story, long=false
      vars = {
        story_id: story.id,
        requested_by: story.requested_by,
        name: truncate(story.name),
        story_type: story_type_icon(story),
        estimate: estimate_points(story),
        owner: story_owner(story),
        description: story.description,
        labels: story_labels(story).colorize(:blue),
        started: story_state_sign(story)
      }
      if long
        "STORY %{started} %{story_type} [#%{story_id}]
        Name:         %{name}
        Labels:       %{labels}
        Owned by:     %{owner}
        Requested by: %{requested_by}
        Description:  %{description}
        Estimate:     %{estimate}" % vars
      else
        "[#%{story_id}] (%{started}) %{story_type} [%{estimate} pts.] %{owner} %{name} %{labels}".colorize(story_color(story)) % vars
      end
    end

    def users_story?(story)
      story.owned_by == user_name
    end

    def story_color story
      if users_story?(story)
        case story.story_type
          when "feature" then :green
          when "bug" then :red
          when "chore" then :yellow
          else :white
        end
      else
        case story.story_type
          when "feature" then :light_green
          when "bug" then :light_red
          when "chore" then :ligh_yellow
          else :light_white
        end
      end
    end

    def print_tasks tasks
      tasks.each { |task| puts task_string(task) }
    end

    def print_notes notes
      notes.each { |note| puts note_string(note) }
    end

    def note_string note
      "\t[#{note.noted_at.to_time}] (#{note.author}) #{note.text}"
    end

    def task_string task
      complete = task.complete ? "x" : " "
      "\t[#{complete}] #{task.description}"
    end

    def story_type_icon story
      type = story.story_type
      space_count = 7 - type.length
      type + " " * space_count
    end

    def truncate string
      string.length > 80 ? "#{string[0..80]}..." : string
    end

    def story_owner story
      story.owned_by.nil? ? "(--)" : "(#{initials(story.owned_by)})"
    end

    def story_labels story
      story.labels.nil? ? "" : story.labels.split(",").map{ |l| "##{l}" }.join(", ")
    end

    def story_state_sign story
      return "*" if story.current_state == "unstarted"
      story.current_state[0].capitalize
    end

    def initials name
      name.split.map{ |n| n[0] }.join
    end

    def estimate_points story
      unless story.estimate.nil?
        story.estimate < 0 ? "?" : story.estimate
      else
        "-"
      end
    end

    def pick_up_story story_id
      save_story_id_to_file(story_id) if start_story(story_id)
    end

    def update_story story_id, state
      story = find_story(story_id)
      if story.nil?
        puts "Story not found, sorry."
        return
      end
      state = :accepted if story.story_type == "chore" && state == :finished
      if story.update(owned_by: user_name, current_state: state).errors.count.zero?
        puts "Story updated in Pivotal Tracker"
        true
      else
        error_message = "ERROR"
        error_message += ": #{story.errors.first}"
        puts error_message
      end
    end

    def start_story story_id
      update_story(story_id, :started)
    end

    def finish_story story_id
      remove_story_id_file if story_id.nil? or update_story(story_id, :finished)
    end

    def deliver_story story_id
      update_story(story_id, :delivered)
    end

    def remove_story_id_file
      FileUtils.remove_file(@story_id_file_path)
    end

    def save_story_id_to_file story_id
      FileUtils.mkdir_p(@story_id_tmp_path)
      File.open(@story_id_file_path, 'w') { |f| f.write(story_id) }
    end

    def show_stories count=9
      stories = user_stories + other_users_stories
      list_stories_to_output stories.first(count)
    end

    def fetch_stories(count = 100, state = "unstarted,started,unscheduled,rejected", story_type = "feature,chore,bug")
      ensure_project do
        conditions = { current_state: state, limit: count, story_type: story_type }
        @options[:stories] = @options[:project].stories.all(conditions)
      end
    end

  end
end
