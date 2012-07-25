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
        stories.each { |story| menu.choice("[##{story.id}] (requested by: #{story.requested_by}) #{story.name}\n\t#{story.description}") { |answer| puts "thanks for picking ##{answer.match(/\[#(?<id>\d+)\]/)[:id]}"} }
      end

    end

    def show_stories
      stories = user_stories
      if stories.count.zero?
        puts "hmm... there is no story assigned to you! I'll better check for unasigned stories!"
        stories = unasigned_stories
      end
      list_stories_to_output stories.last(5)
    end

    def fetch_stories(count = 100, state = "unstarted")
      conditions = { current_state: state, limit: count }
      @options[:stories] = @options[:project].stories.all(conditions)
    end

  end
end
