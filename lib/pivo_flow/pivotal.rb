# -*- encoding : utf-8 -*-
module PivoFlow
  class Pivotal < Base

    def run
      @story_id_file_name = ".pivotal_story_id"
      @story_id_tmp_path = File.join(@current_dir, "/tmp")
      @story_id_file_path = File.join(@story_id_tmp_path, @story_id_file_name)

      return 1 unless @options["api-token"] && @options["project-id"]
      PivotalTracker::Client.token = @options["api-token"]
      PivotalTracker::Client.use_ssl = true
      @options[:project] ||= PivotalTracker::Project.find(@options["project-id"])
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

    def current_story force = false
      if (@options[:current_story] && !force)
        @options[:current_story]
      else
        @options[:current_story] = user_stories.count.zero? ? nil : user_stories.first
      end
    end

    def list_stories_to_output stories
      if current_story
        puts "You've got some started stories, it may be a good idea to finish them in the first place"
        puts "[##{current_story.id}] #{current_story.name} - #{current_story.description}"
      end

      HighLine.new.choose do |menu|
        menu.header = "--- STORIES FROM PIVOTAL TRACKER ---\nWhich one would you like to start?   "
        menu.prompt = "story no.? "
        menu.select_by = :index
        stories.each do |story|
          vars = {
            story_id: story.id,
            requested_by: story.requested_by,
            name: story.name,
            story_type: story_type_icon(story),
            estimate: estimate_points(story),
            owner: story_owner(story),
            started: story.current_state == "started" ? "started >" : ""
          }
          story_text = "%{started} [#%{story_id}] %{story_type} [%{estimate} pts.] %{owner} %{name}" % vars
          story_text += "\n   Description: #{story.description}" unless story.description
          menu.choice(story_text) { |answer| pick_up_story(answer.match(/\[#(?<id>\d+)\]/)[:id])}
        end
      end
    end

    def story_type_icon story
      case story.story_type
        when "feature" then "☆"
        when "bug" then "☠"
        when "chore" then "✙"
        else "☺"
      end
    end

    def story_owner story
      story.owned_by.nil? ? "" : "(#{initials(story.owned_by)})"
    end

    def initials name
      name.split.map{ |n| n[0]}.join
    end

    def estimate_points story
      unless story.estimate.nil?
        story.estimate < 0 ? "?" : story.estimate
      else
        "no"
      end
    end

    def pick_up_story story_id
      save_story_id_to_file(story_id) if start_story(story_id)
    end

    def update_story story_id, state
      story = @options[:project].stories.find(story_id)
      if story.nil?
        puts "Story not found, sorry."
      end
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

    def remove_story_id_file
      FileUtils.remove_file(@story_id_file_path)
    end

    def save_story_id_to_file story_id
      FileUtils.mkdir_p(@story_id_tmp_path)
      File.open(@story_id_file_path, 'w') { |f| f.write(story_id) }
    end

    def show_stories
      stories = user_stories + other_users_stories
      list_stories_to_output stories.first(9)
    end

    def fetch_stories(count = 100, state = "unstarted,started,unscheduled")
      conditions = { current_state: state, limit: count }
      @options[:stories] = @options[:project].stories.all(conditions)
    end

  end
end
