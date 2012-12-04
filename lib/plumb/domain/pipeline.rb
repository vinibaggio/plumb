require 'ostruct'

module Plumb
  module Domain
    class Pipeline < OpenStruct
      def ==(other)
        self.name == other.name
      end

      def attributes
        @table
      end
    end
  end
end
