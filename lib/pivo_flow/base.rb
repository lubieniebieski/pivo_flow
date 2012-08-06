module PivoFlow
  class Base
    GIT_DIR = '.git'
    KEYS_TO_CHECK = ["test-pivotal.project-id", "test-pivotal.api-token"]

    def initialize(*args)
      @options = {}
      @current_dir = Dir.pwd
      return "no GIT (#{GIT_DIR}) directory found" unless File.directory?(File.join(@current_dir, GIT_DIR))

      # paths
      @git_dir = File.join(@current_dir, GIT_DIR)
      @git_hook_path = File.join(@git_dir, 'hooks', 'prepare-commit-msg')
      @pf_git_hook_name = 'pf-prepare-commit-msg'
      @pf_git_hook_path = File.join(@git_dir, 'hooks', @pf_git_hook_name)

      @options[:repository] = Grit::Repo.new(@git_dir)
      install_git_hook if git_hook_needed?
      git_config_ok? ? parse_git_config : add_git_config
      run
    end

    def git_hook_needed?
      !File.executable?(@git_hook_path) || !File.read(@git_hook_path).match(/\.\/#{@pf_git_hook_name}/)
    end

    def install_git_hook
      puts "Installing prepare-commit-msg hook..."
      hook_path = File.join(File.dirname(__FILE__), '..', '..', 'bin', @pf_git_hook_name)
      FileUtils.cp(hook_path, @pf_git_hook_path, preserve: true)
      puts "File copied..."
      unless File.exists?(@git_hook_path) && File.read(@git_hook_path).match(/\.\/#{@pf_git_hook_name}/)
        File.open(@git_hook_path, "a") { |f| f.puts("./#{@pf_git_hook_path} $1") }
        puts "Reference to pf-prepare-commit-msg added to prepare-commit-msg..."
      end
      unless File.executable?(@git_hook_path)
        FileUtils.chmod 0755, @git_hook_path unless
        puts "Chmod on #{@git_hook_path} set to 755"
      end

      puts "Success!\n"
    end

    def run
      raise "you should define run!"
    end

    def user_name
      @options[:user_name] ||= @options[:repository].config['pivotal.full-name'] || @options[:repository].config['user.name']
    end

    private

    def git_config_ok?
      !KEYS_TO_CHECK.any? { |key| @options[:repository].config[key].nil? }
    end

    def add_git_config
      ask_question_and_update_config "Pivotal: what is your project's ID?", "test-pivotal.project-id"
      ask_question_and_update_config "Pivotal: what is your pivotal tracker api-token?", "test-pivotal.api-token"
      parse_git_config
    end

    def parse_git_config
      KEYS_TO_CHECK.each do |key|
        new_key = key.split(".").last
        @options[new_key] = @options[:repository].config[key]
      end
    end

    def ask_question_and_update_config question, variable
      @options[:repository].config[variable] ||= ask_question(question)
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
