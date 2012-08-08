# require_relative './../../lib/pivo_flow/cli'
require "spec_helper"
describe PivoFlow::Cli do

  it "exists with no_method_error message if no args are provided" do
    PivoFlow::Cli.any_instance.should_receive(:no_method_error)
    -> { PivoFlow::Cli.new }.should raise_error(SystemExit)
  end

  it "exits with invalid_method_error message if provided command is invalid" do
    PivoFlow::Cli.any_instance.should_receive(:invalid_method_error)
    -> { PivoFlow::Cli.new("invalid_method_name") }.should raise_error(SystemExit)
  end

  it "runs given command if it is public" do

    module PivoFlow
      class Cli
        def self.new_method_name
          puts "hi!"
        end
      end
    end

    PivoFlow::Cli.any_instance.should_receive(:new_method_name)
    -> { PivoFlow::Cli.new("new_method_name") }.should raise_error(SystemExit)

  end

  it "should define given methods" do
    methods = [:stories, :start, :finish, :clear, :reconfig, :version]
    (PivoFlow::Cli.methods(false) && methods).should eq methods
  end

end
