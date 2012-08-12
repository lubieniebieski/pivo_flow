require 'simplecov'

SimpleCov.start
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pivo_flow'
require 'vcr'
require 'rspec'

VCR.configure do |c|
  c.hook_into :fakeweb # or :fakeweb
  c.cassette_library_dir = 'spec/pivo_flow/vcr_cassettes'
end

def stub_git_config(options = {})
  git_options = {
    "pivo-flow.api-token" => "testtesttesttesttesttesttesttest",
    "pivo-flow.project-id" => "123456",
    "user.name" => "Adam Newman"
  }.merge options
  Grit::Repo.stub!(:new).and_return mock('Grit::Repo', :config => git_options)
  PivoFlow::Base.any_instance.stub(:git_hook_needed?).and_return(false)
  PivoFlow::Base.any_instance.stub(:git_directory_present?).and_return(true)
  PivoFlow::Base.any_instance.stub(:git_config_ok?).and_return(true)
end
