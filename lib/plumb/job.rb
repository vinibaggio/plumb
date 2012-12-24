require 'ostruct'
require 'json'

module Plumb
  class Job < OpenStruct
    def to_json(*)
      JSON.generate(@table)
    end

    def last_build_status
      super.capitalize
    end
  end
end

