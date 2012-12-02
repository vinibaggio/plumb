require 'ostruct'

module Plumb
  module Domain
    class Job < OpenStruct
      def attributes
        @table
      end
    end
  end
end

