module PivoFlow
  class Pivotal < Base

    def run
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
      HighLine.new.choose do |menu|
        menu.header = "--- STORIES FROM PIVOTAL TRACKER ---\nWhich one would you like to start?   "
        menu.prompt = "story no.? "
        menu.select_by = :index
        stories.each do |story|
          vars = {
            story_id: story.id,
            requested_by: story.requested_by,
            name: story.name,
            estimate: story.estimate < 0 ? "?" : story.estimate
          }
          story_text = "[#%{story_id}] [%{estimate} pts.] (requested by: %{requested_by}) %{name}" % vars
          story_text += "\n   Description: #{story.description}" unless story.description.empty?
          menu.choice(story_text) { |answer| puts "thanks for picking ##{answer.match(/\[#(?<id>\d+)\]/)[:id]}"}
        end
      end
    end

    def pick_up_story story_id
      save_story_id_to_file(story_id) if start_story(story_id)
    end

    def start_story story_id
      story = @options[:project].stories.find(story_id)
      if story.nil?
        puts "Story not found, sorry."
        nil
      end
      if story.update(owned_by: user_name, current_state: :started).errors.count.zero?
        puts "Story updated in Pivotal Tracker"
      else
        error_message = "ERROR"
        error_message += ": #{story.errors.first}"
        puts error_message
        nil
      end

    end

    def save_story_id_to_file story_id
      tmp_path = File.join(@current_dir, "/tmp")
      story_file = ".pivotal_story_id"
      FileUtils.mkdir_p(tmp_path)
      File.open(File.join(tmp_path, story_file), 'w') { |f| f.write(story_id) }
    end

    def show_stories
      stories = user_stories + unasigned_stories
      if stories.count.zero?
        puts "hmm... there is no story assigned to you! I'll better check for unasigned stories!"
        stories = unasigned_stories
      end
      list_stories_to_output stories.first(10)
    end

    def fetch_stories(count = 100, state = "unstarted,unscheduled")
      conditions = { current_state: state, limit: count }
      @options[:stories] = @options[:project].stories.all(conditions)
    end

  end
end
