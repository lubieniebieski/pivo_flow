module PivoFlow
  class Base
    GIT_DIR = '.git'
    KEYS_TO_CHECK = ["test-pivotal.project-id", "test-pivotal.api-token"]

    def initialize(*args)
      @options = {}
      current_dir = Dir.pwd
      return "no GIT (#{GIT_DIR}) directory found" unless File.directory?(File.join(current_dir, GIT_DIR))
      git_dir = File.join(current_dir, GIT_DIR)
      @repository = Grit::Repo.new(git_dir)
      git_config_ok? ? parse_git_config : add_git_config
      puts @options
      puts "FINISH!"
    end

    def git_config_ok?
      !KEYS_TO_CHECK.any? { |key| @repository.config[key].nil? }
    end

    def add_git_config
      ask_question_and_update_config "Pivotal: what is your project's ID?", "test-pivotal.project-id"
      ask_question_and_update_config "Pivotal: what is your pivotal tracker api-token?", "test-pivotal.api-token"
    end

    def parse_git_config
      KEYS_TO_CHECK.each do |key|
        new_key = key.split(".").last
        @options[new_key] = @repository.config[key]
      end
    end

    def ask_question_and_update_config question, variable
      @repository.config[variable] ||= ask_question(question)
    end

    def ask_question question, first_answer = nil
      h = HighLine.new
      h.ask("#{question}\t") do |q|
        q.responses[:ask_on_error] = :question
        q.responses[:not_valid] = "It can't be empty, sorry"
        q.validate = ->(id) { !id.empty? }
        q.first_answer = first_answer
      end
    end

  end
end
