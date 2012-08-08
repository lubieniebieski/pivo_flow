require_relative './../../lib/pivo_flow/cli'

describe PivoFlow::Cli do

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

    let(:command) { PivoFlow::Cli.new("new_method_name").go! }

    module PivoFlow
      class Cli
        def self.new_method_name
          puts "hi!"
        end
      end
    end

    before do
      PivoFlow::Cli.any_instance.should_receive(:new_method_name)
    end

    it "runs this command if it is public" do
      command
    end

    it "returns 0" do
      expect(command).to eq 0
    end

  end

  it "should define given methods" do
    methods = [:stories, :start, :finish, :clear, :reconfig, :version]
    (PivoFlow::Cli.methods(false) && methods).should eq methods
  end

end
