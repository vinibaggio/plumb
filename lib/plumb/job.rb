require 'ostruct'
require 'json'

module Plumb
  class Job < OpenStruct
    def to_json
      JSON.generate(@table)
    end
  end
end

