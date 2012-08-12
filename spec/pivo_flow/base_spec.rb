require "spec_helper"
require_relative './../../lib/pivo_flow/errors'
describe PivoFlow::Base do

  let(:base) { PivoFlow::Base.new }

  before do
    PivoFlow::Base.any_instance.stub(:puts)
    stub_git_config
    stub_base_methods(PivoFlow::Base)
  end

  it "raises exception if it's outside of git repo" do
    PivoFlow::Base.any_instance.stub(:git_directory_present?).and_return(false)
    expect{base}.to raise_error(PivoFlow::Errors::NoGitRepoFound)
  end

  it "calls hook installation if it's needed" do
    PivoFlow::Base.any_instance.stub(:git_hook_needed?).and_return(true)
    PivoFlow::Base.any_instance.should_receive(:install_git_hook)
    base
  end

  describe "pre commit hoook" do

    let(:file_name) { ".git/hooks/prepare-commit-msg" }
    let(:pf_file_name) { ".git/hooks/pf-prepare-commit-msg" }

    before do
      File.delete file_name if File.exists? file_name
      base
    end

    it "creates an executable prepare-commit-msg file" do
      base.install_git_hook
      File.executable?(file_name).should be_true
    end

    it "creates an executable pf-prepare-commit-msg file" do
      File.delete pf_file_name if File.exists? pf_file_name
      base.install_git_hook
      File.executable?(pf_file_name).should be_true
    end

  end

  describe "parses git config" do

    it "and returns project id" do
      base.options["project-id"].should eq "123456"
    end

    it "and returns api token" do
      base.options["api-token"].should eq "testtesttesttesttesttesttesttest"
    end

    it "returns user name" do
      base.user_name.should eq "Adam Newman"
    end

  end

  describe "adding configuration" do

    before(:each) do
      stub_git_config({
        'pivo-flow.api-token' => nil,
        'pivo-flow.project-id' => nil}
        )
      PivoFlow::Base.any_instance.stub(:git_config_ok?).and_return(false)

    end

    PivoFlow::Base::KEYS_AND_QUESTIONS.each do |key, value|
      it "changes #{key} value" do
        PivoFlow::Base.any_instance.stub(:ask_question).and_return(key)
        new_key = key.split(".").last
        base.options[new_key].should eq key
      end
    end

  end

end
