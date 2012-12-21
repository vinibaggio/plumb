require 'ostruct'
require 'json'

module Plumb
  module Domain
    class Job < OpenStruct
      def to_json
        JSON.generate(@table)
      end
    end
  end
end

