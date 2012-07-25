module PivoFlow
  class Cli

    def initialize *args
      if args.length.zero?
        puts "You forgot method name"
        exit 1
      end
      parse_argv(*args)
    end


    private

    def valid_method? method_name
      self.methods.include? method_name.to_sym
    end

    def parse_argv(*args)
      command = args.first.split.first
      unless valid_method?(command)
        puts "Ups, no such method..."
        exit 1
      end
      send(command)
      exit 0
    end

  end
end
