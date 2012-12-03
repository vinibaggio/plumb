require 'ostruct'

module Plumb
  module Domain
    class Pipeline < OpenStruct
      def attributes
        @table
      end
    end
  end
end
