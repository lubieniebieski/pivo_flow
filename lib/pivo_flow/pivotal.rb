module PivoFlow
  class Pivotal < Base

    def run
      return 1 unless @options["api-token"] && @options["project-id"]
      PivotalTracker::Client.token = @options["api-token"]
      PivotalTracker::Client.use_ssl = true
      @options[:project] ||= PivotalTracker::Project.find(@options["project-id"])
    end

    def user_stories
      fetch_stories(5, user_name)
    end

    def unasigned_stories
      fetch_stories(5)
    end

    def current_story force = false
      if (@options[:current_story] && !force)
        @options[:current_story]
      else
        stories = fetch_stories(1, user_name, "started")
        @options[:current_story] = stories.count.zero? ? user_stories.first : stories.first
      end
    end

    def list_stories_to_output stories
      HighLine.new.choose do |menu|
        menu.prompt = "Which one would you like to start?   "
        stories.each { |story| menu.choice("[##{story.id}] #{story.name}\n\t#{story.description}") { |answer| puts "thanks for picking ##{answer.match(/\[#(?<id>\d+)\]/)[:id]}"} }
      end

    end

    def show_stories
      stories = user_stories.count.zero? ? unasigned_stories : user_stories
      list_stories_to_output stories
    end

    def fetch_stories(count = 1, owned_by = nil, state = "unstarted")
      conditions = { current_state: state, limit: count, owned_by: owned_by }
      @options[:project].stories.all(conditions)
    end

  end
end
