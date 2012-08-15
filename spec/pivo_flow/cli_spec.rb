require_relative './../../lib/pivo_flow/cli'

describe PivoFlow::Cli do

  before(:each) do
    # we don't need cli output all over the specs
    PivoFlow::Cli.any_instance.stub(:puts)
  end

  describe "with no args provided" do

    let(:command) { PivoFlow::Cli.new.go! }

    before(:each) do
      PivoFlow::Cli.any_instance.should_receive(:no_method_error).and_return(true)
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
      PivoFlow::Cli.any_instance.should_receive(:invalid_method_error)
    end

    it "calls invalid_method_error message" do
      command
    end

    it "returns 1" do
      expect(command).to eq 1
    end

  end

  describe "with valid command" do
    cmd = "stories"
    let(:command) { PivoFlow::Cli.new(cmd).go! }

    before do
      PivoFlow::Cli.any_instance.should_receive(cmd.to_sym)
    end

    it "runs this command if it is public" do
      command
    end

    it "returns 0" do
      expect(command).to eq 0
    end

  end

  describe "reads story id from file" do

    it "and returns nil if there is no such file" do
      File.stub(:exists?).and_return(false)
      PivoFlow::Cli.new.send(:current_story_id).should be_nil
    end

    it "and returns story id if file exists" do
      File.stub(:exists?).and_return(true)
      f = mock('File', :read => "123")
      File.stub(:open).and_return(f)
      PivoFlow::Cli.new.send(:current_story_id).should eq "123"
    end
  end

  describe "finish method" do

    it "calls finish_story on pivotal object on finish method" do
      pivo = mock("PivoFlow::Pivotal")
      PivoFlow::Cli.any_instance.should_receive(:pivotal_object).and_return(pivo)
      pivo.should_receive(:finish_story).with("123")
      PivoFlow::Cli.any_instance.should_receive(:current_story_id).twice.and_return("123")
      PivoFlow::Cli.new("finish").go!
    end

    it "returns 1 if there is no current_story_id" do
      PivoFlow::Cli.any_instance.should_receive(:current_story_id).and_return(nil)
      PivoFlow::Cli.new.send(:finish).should eq 1
    end
  end

  describe "start method" do

    it "returns 1 if no story given" do
      PivoFlow::Cli.new.send(:start).should eq 1
    end

  end

  describe "clear method" do

    it "returns 1 if current story is nil" do
      PivoFlow::Cli.any_instance.should_receive(:current_story_id).and_return(nil)
      PivoFlow::Cli.new.send(:clear).should eq 1
    end


    it "removes file if current story is present" do
      PivoFlow::Cli.any_instance.should_receive(:current_story_id).and_return(1)
      FileUtils.should_receive(:remove_file).and_return(true)
      PivoFlow::Cli.new.send(:clear)
    end

  end


  describe "should allow to run command named" do
    methods = [:stories, :start, :info, :finish, :clear, :help, :reconfig, :current, :deliver]
    methods.each do |method|
      it "#{method.to_s}" do
        PivoFlow::Cli.any_instance.stub(method)
        PivoFlow::Cli.new(method.to_s).go!.should eq 0
      end
    end
  end

end
