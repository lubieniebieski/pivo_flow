require "spec_helper"
require_relative './../../lib/pivo_flow/errors'

describe PivoFlow::Base do
  let(:base) { PivoFlow::Base.new }

  before do
    allow_any_instance_of(PivoFlow::Base).to receive(:puts)

    stub_git_config
    stub_base_methods(PivoFlow::Base)
  end

  it "raises exception if it's outside of git repo" do
    allow_any_instance_of(PivoFlow::Base).to receive(:git_directory_present?)
      .and_return(false)

    expect{ base }.to raise_error(PivoFlow::Errors::NoGitRepoFound)
  end

  it "calls hook installation if it's needed" do
    allow_any_instance_of(PivoFlow::Base).to receive(:git_hook_needed?).and_return(true)
    allow_any_instance_of(PivoFlow::Base).to receive(:install_git_hook)

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
      expect(File.executable?(file_name)).to be_truthy
    end

    it "creates an executable pf-prepare-commit-msg file" do
      File.delete pf_file_name if File.exists? pf_file_name
      base.install_git_hook
      expect(File.executable?(pf_file_name)).to be_truthy
    end

  end

  describe "parses git config" do

    it "and returns project id" do
      expect(base.options["project-id"]).to eq "123456"
    end

    it "and returns api token" do
      expect(base.options["api-token"]).to eq "testtesttesttesttesttesttesttest"
    end

    it "returns user name" do
      expect(base.user_name).to eq "Adam Newman"
    end

  end

  describe "adding configuration" do

    before(:each) do
      stub_git_config({
        'pivo-flow.api-token' => nil,
        'pivo-flow.project-id' => nil}
        )

      allow_any_instance_of(PivoFlow::Base).to receive(:git_config_ok?).and_return(false)
    end

    PivoFlow::Base::KEYS_AND_QUESTIONS.each do |key, value|
      it "changes #{key} value" do
        allow_any_instance_of(PivoFlow::Base).to receive(:ask_question).and_return(key)
        new_key = key.split(".").last
        expect(base.options[new_key]).to eq key
      end
    end
  end
end
