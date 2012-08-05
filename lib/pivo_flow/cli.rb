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
