module Plumb
  class Commit
    class InvalidSHA < Exception; end

    attr_reader :sha

    def initialize(sha)
      @sha = sha
      raise InvalidSHA if !sha || sha.strip == ''
    end

    def to_json(*)
      %Q("#{sha}")
    end

    def ==(other)
      sha == other.sha
    end
  end
end
