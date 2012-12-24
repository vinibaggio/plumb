require 'json'
require 'ostruct'

module Plumb
  class BuildStatus < OpenStruct
    def failure?
      status == :failure
    end

    def success?
      status == :success
    end

    def to_json
      JSON.generate(@table)
    end
  end
end

