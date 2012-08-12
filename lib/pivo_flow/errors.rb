module PivoFlow
  module Errors
    exceptions_list = %w[ NoGitRepoFound UnsuccessfulPivotalConnection ]
    exceptions_list.each { |e| const_set(e, Class.new(StandardError)) }

    def self.exceptions
      self.constants.map { |d| self.const_get(d) }
    end

  end
end
