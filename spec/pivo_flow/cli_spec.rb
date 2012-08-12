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
  describe "should allow to run command named" do
    methods = [:stories, :start, :info, :finish, :clear, :reconfig]
    methods.each do |method|
      it "#{method.to_s}" do
        PivoFlow::Cli.any_instance.stub(method)
        PivoFlow::Cli.new(method.to_s).go!.should eq 0
      end
    end
  end

end
