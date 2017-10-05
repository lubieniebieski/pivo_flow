require_relative './../../lib/pivo_flow/cli'

describe PivoFlow::Cli do

  before(:each) do
    # we don't need cli output all over the specs
    allow_any_instance_of(PivoFlow::Cli).to receive(:puts)
  end

  describe "with no args provided" do

    let(:command) { PivoFlow::Cli.new.go! }

    before(:each) do
      expect_any_instance_of(PivoFlow::Cli).to receive(:no_method_error).and_return(true)
    end

    it "calls no_method_error message " do
      command
    end

    it "returns 1" do
      expect(command).to eq 1
    end

  end

  describe "on invalid command" do

    let(:command) { PivoFlow::Cli.new("invalid_method_name").go! }

    before(:each) do
      expect_any_instance_of(PivoFlow::Cli).to receive(:invalid_method_error)
    end

    it "calls invalid_method_error message" do
      command
    end

    it "returns 1" do
      expect(command).to eq 1
    end

  end

  describe "with valid command" do
    let(:cmd) { "stories" }
    let(:command) { PivoFlow::Cli.new(cmd).go! }

    before do
      expect_any_instance_of(PivoFlow::Cli).to receive(cmd.to_sym)
    end

    it "runs this command if it is public" do
      command
    end

    it "returns 0" do
      expect(command).to eq 0
    end
  end

  describe "finish method" do
    it "calls finish_story on pivotal object on finish method" do
      pivo = instance_double("PivoFlow::Pivotal")
      expect_any_instance_of(PivoFlow::Cli).to receive(:pivotal_object).and_return(pivo)
      expect(pivo).to receive(:finish_story).with("123")
      expect_any_instance_of(PivoFlow::Cli).to receive(:current_story_id).twice.and_return("123")
      PivoFlow::Cli.new("finish").go!
    end

    it "returns 1 if there is no current_story_id" do
      expect_any_instance_of(PivoFlow::Cli).to receive(:current_story_id).and_return(nil)
      expect(PivoFlow::Cli.new.send(:finish)).to eq 1
    end
  end

  describe "start method" do

    it "returns 1 if no story given" do
      expect(PivoFlow::Cli.new.send(:start)).to eq 1
    end

  end

  describe "clear method" do

    it "returns 1 if current story is nil" do
      expect_any_instance_of(PivoFlow::Cli).to receive(:current_story_id).and_return(nil)
      expect(PivoFlow::Cli.new.send(:clear)).to eq 1
    end


    it "removes file if current story is present" do
      expect_any_instance_of(PivoFlow::Cli).to receive(:current_story_id).and_return(1)
      expect(FileUtils).to receive(:remove_file).and_return(true)
      PivoFlow::Cli.new.send(:clear)
    end

  end


  describe "should allow to run command named" do
    methods = [:stories, :start, :info, :finish, :clear, :help, :reconfig, :current, :deliver]
    methods.each do |method|
      it "#{method.to_s}" do
        allow_any_instance_of(PivoFlow::Cli).to receive(method)
        expect(PivoFlow::Cli.new(method.to_s).go!).to eq 0
      end
    end
  end

end
