require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pivo_flow'
require 'vcr'
require 'rspec'

VCR.configure do |c|
  c.hook_into :fakeweb # or :fakeweb
  c.cassette_library_dir = 'spec/pivo_flow/vcr_cassettes'
end

module StubHelpers
  def stub_git_config(options = {})
    git_options = {
      "pivo-flow.api-token" => "testtesttesttesttesttesttesttest",
      "pivo-flow.project-id" => "123456",
      "user.name" => "Adam Newman"
    }.merge(options)

    allow(Grit::Repo).to receive(:new) do
      instance_double('Grit::Repo', config: git_options)
    end
  end

  def stub_base_methods(klass)
    allow_any_instance_of(klass).to receive(:git_hook_needed?) { false }
    allow_any_instance_of(klass).to receive(:git_directory_present?) { true }
    allow_any_instance_of(klass).to receive(:git_config_ok?) { true }
  end
end

RSpec.configure do |config|
  config.include StubHelpers
end
