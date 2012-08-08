module PivoFlow
  class Cli

    def initialize *args
      @file_story_path = File.join(Dir.pwd, "/tmp/.pivotal_story_id")
      @args = args
    end

    def go!
      if @args.empty?
        no_method_error
        return 1
      end
      # catch interrupt signal (CTRL+C)
      Signal.trap(2) {
        puts "\nkkthxbye!"
        return 0
      }
      return parse_argv(@args)
    end

    def stories
      pivotal_object.show_stories
    end

    def start story_id
      pivotal_object.pick_up_story(story_id)
    end

    def finish story_id=nil
      if File.exists? @file_story_path
        story_id = File.open(@file_story_path).read.strip
      end
      pivotal_object.finish_story(story_id)
    end

    def clear
      if File.exists? @file_story_path
        FileUtils.remove_file(@file_story_path)
      end
      puts "Current pivotal story id cleared."
    end

    def reconfig
      PivoFlow::Base.new.reconfig
    end

    def version
      puts PivoFlow::VERSION
    end

    private

    def pivotal_object
      @pivotal_object ||= PivoFlow::Pivotal.new
    end

    def no_method_error
      puts "You forgot method name"
    end

    def invalid_method_error
      puts "Ups, no such method..."
    end

    def valid_method? method_name
      self.methods.include? method_name.to_sym
    end

    def parse_argv(args)
      command = args.first
      args = args.slice(1..-1)

      unless valid_method?(command)
        invalid_method_error
        return(1)
      end
      send(command, *args)
      return(0)
    end

  end
end
