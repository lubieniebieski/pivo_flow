module PivoFlow
  class Cli

    def initialize *args
      @file_story_path = File.join(Dir.pwd, "/tmp/.pivotal_story_id")
      @args = args
    end

    def go!
      Signal.trap(2) {
        puts "\nkkthxbye!"
        return 0
      }
      begin
        return parse_argv(@args)
      rescue *PivoFlow::Errors.exceptions => e
        puts "[ERROR] #{e}"
        return 1
      end
    end

    private

    # available commands

    def stories
      pivotal_object.show_stories
    end

    def start story_id=nil
      unless story_id
        puts "Ok, but which story?"
        return 1
      end
      pivotal_object.pick_up_story(story_id)
    end

    def finish story_id=nil
      unless current_story_id
        puts no_story_found_message
        return 1
      end
      pivotal_object.finish_story(current_story_id)
    end

    def clear
      unless current_story_id.nil?
        FileUtils.remove_file(@file_story_path)
        puts "Current pivotal story id cleared."
      else
        puts no_story_found_message
        return 1
      end
    end

    def current
      puts current_story_id || no_story_found_message
    end

    def reconfig
      PivoFlow::Base.new.reconfig
    end

    def info
      pivotal_object.show_info
    end

    def version
      puts PivoFlow::VERSION
    end

    # additional methods

    def pivotal_object
      @pivotal_object ||= PivoFlow::Pivotal.new(@options)
    end

    def no_story_found_message
      "No story found in #{@file_story_path}"
    end

    def no_method_error
      puts "You forgot a method name"
    end

    def invalid_method_error
      puts "Ups, no such method..."
    end

    def current_story_id
      return nil unless File.exists?(@file_story_path)
      File.open(@file_story_path).read.strip
    end

    def parse_argv(args)
      @options = {}

      opt_parser = OptionParser.new do |opts|
        opts.banner =   "Usage: pf <COMMAND> [OPTIONS]\n"
        opts.separator  "Commands"
        opts.separator  "     clear:             clears STORY_ID from temp file"
        opts.separator  "     info:              shows info about current story"
        opts.separator  "     finish [STORY_ID]: finish story on Pivotal"
        opts.separator  "     reconfig:          clears API_TOKEN and PROJECT_ID from git config"
        opts.separator  "     start <STORY_ID>:  start a story of given ID"
        opts.separator  "     stories:           list stories for current project"
        opts.separator  ""
        opts.separator  "Options"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          return 1
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts PivoFlow::VERSION
          return 1
        end

        opts.on("-t <API_TOKEN>", "--token <API_TOKEN>", "Sets Pivotal Tracker API TOKEN") do |api_token|
          @options["api-token"] = api_token
        end

        opts.on("-p <PROJECT_ID>", "--project <PROJECT_ID>", Numeric, "Sets Pivotal Tracker PROJECT_ID") do |project_id|
          @options["project-id"] = project_id
        end

      end

      opt_parser.parse!(args)

      case args[0]
      when "start", "finish"
        self.send(args[0].to_sym, args[1])
      when "clear", "current", "reconfig", "stories", "info"
        self.send(args[0].to_sym)
      when nil
        no_method_error
        puts opt_parser.to_s
        return 1
      else
        invalid_method_error
        return 1
      end
      return 0

    end

  end

end
