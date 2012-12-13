require 'ostruct'
require 'json'

module Plumb
  module Domain
    class Job < OpenStruct
      def attributes
        @table
      end

      def to_json
        JSON.generate(
          'script' => script
        )
      end
    end
  end
end

