module PivoFlow
  module Errors
    exceptions = %w[ NoGitRepoFound ]
    exceptions.each { |e| const_set(e, Class.new(StandardError)) }
  end
end
