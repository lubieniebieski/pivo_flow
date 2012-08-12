module PivoFlow

  # This class is responsible for setting up the project environment
  #
  # * saving Pivotal Tracker API token and project ID in git repository config
  # * installing git hook

  class Base
    attr_reader :options
    # Git repository directory
    GIT_DIR = '.git'
    # Keys used by gem in git config, with corresponding questions which are
    # used during project setup
    KEYS_AND_QUESTIONS = {
      "pivo-flow.project-id"  => "Pivotal: what is your project's ID?",
      "pivo-flow.api-token"   => "Pivotal: what is your pivotal tracker api-token?"
    }

    # Basic initialize method
    def initialize(options={})
      @options = options
      @current_dir = Dir.pwd

      raise PivoFlow::Errors::NoGitRepoFound, "No git repository found" unless git_directory_present?

      # paths
      @git_dir = File.join(@current_dir, GIT_DIR)
      @git_hook_path = File.join(@git_dir, 'hooks', 'prepare-commit-msg')
      @pf_git_hook_name = 'pf-prepare-commit-msg'
      @pf_git_hook_path = File.join(@git_dir, 'hooks', @pf_git_hook_name)
      @pf_git_hook_cmd = "#{@pf_git_hook_path} $1"
      @options[:repository] = Grit::Repo.new(@git_dir)

      install_git_hook if git_hook_needed?
      git_config_ok? ? parse_git_config : add_git_config
      run
    end

    # Check if git hook is already installed
    def git_hook_needed?
      !File.executable?(@git_hook_path) || !File.read(@git_hook_path).match(/#{@pf_git_hook_name} \$1/)
    end

    def git_directory_present?
      File.directory?(File.join(@current_dir, GIT_DIR))
    end

    # Install git hook
    # Copy hook to <tt>.git/hooks</tt> directory and add a reference to this
    # executable file within <tt>prepare-commit-msg</tt> hook (it may be
    # helpful if user has his custom hooks)
    def install_git_hook
      puts "Installing prepare-commit-msg hook..."
      hook_path = File.join(File.dirname(__FILE__), '..', '..', 'bin', @pf_git_hook_name)
      FileUtils.cp(hook_path, @pf_git_hook_path, preserve: true)
      puts "File copied..."
      unless File.exists?(@git_hook_path) && File.read(@git_hook_path).match(@pf_git_hook_cmd)
        File.open(@git_hook_path, "a") { |f| f.puts(@pf_git_hook_cmd) }
        puts "Reference to pf-prepare-commit-msg added to prepare-commit-msg..."
      end
      unless File.executable?(@git_hook_path)
        FileUtils.chmod 0755, @git_hook_path unless
        puts "Chmod on #{@git_hook_path} set to 755"
      end

      puts "Success!\n"
    end

    # This method is fired after initialization and should be overwritten by
    # subclasses
    def run
    end

    # Get full user name from git config, i.e. Adam Newman
    def user_name
      @options[:user_name] ||= @options[:repository].config['pivotal.full-name'] || @options[:repository].config['user.name']
    end

    # Setup project by entering Pivotal <tt>api-token</tt> and Pivotal Tracker <tt>project_id</tt>
    def reconfig
      KEYS_AND_QUESTIONS.each do |key, question|
        ask_question_and_force_update_config(question, key)
      end
      config_update_success
    end

    private

    def config_update_success
      puts "[SUCCESS] Pivotal Tracker configuration has been updated."
    end

    def git_config_ok?
      !KEYS_AND_QUESTIONS.keys.any? { |key| @options[:repository].config[key].nil? }
    end

    def add_git_config
      KEYS_AND_QUESTIONS.each do |key, question|
        ask_question_and_update_config(question, key)
      end
      parse_git_config
    end

    def parse_git_config
      KEYS_AND_QUESTIONS.each do |key, value|
        new_key = key.split(".").last
        @options[new_key] = @options[:repository].config[key]
      end
    end

    def ask_question_and_update_config question, variable
      @options[:repository].config[variable] ||= ask_question(question)
    end

    def ask_question_and_force_update_config question, variable
      @options[:repository].config[variable] = ask_question(question)
    end

    def update_config_from_options
      KEYS_AND_QUESTIONS.keys.each do |key|
        @options[:repository].config[key] = @options[key.gsub(/-/, "_")]
      end
      config_update_success
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
