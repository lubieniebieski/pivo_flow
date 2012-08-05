module PivoFlow
  class Cli

    def initialize *args
      if args.length.zero?
        puts "You forgot method name"
        exit 1
      end
      parse_argv(*args)
    end

    def stories
      PivoFlow::Pivotal.new.show_stories
    end

    def start story_id
      PivoFlow::Pivotal.new.pick_up_story(story_id)
    end

    def finish story_id=nil
      file_story_path = File.join(Dir.pwd, "/tmp/.pivotal_story_id")
      if File.exists? file_story_path
        story_id = File.open(file_story_path).read.strip
      end
      PivoFlow::Pivotal.new.finish_story(story_id)
    end

    private

    def valid_method? method_name
      self.methods.include? method_name.to_sym
    end

    def parse_argv(*args)
      command = args.first.split.first
      args = args.slice(1..-1)

      unless valid_method?(command)
        puts "Ups, no such method..."
        exit 1
      end
      send(command, *args)
      exit 0
    end

  end
end
