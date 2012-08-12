require "spec_helper"

describe PivoFlow::Pivotal do

  let(:pivotal) { PivoFlow::Pivotal.new }

  before do
    stub_git_config
  end

end
