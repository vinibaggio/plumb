require 'ostruct'

module Plumb
  module Domain
    class Build
      attr_reader :pipeline, :job, :commits

      def initialize(attributes = {})
        @commits, @job, @pipeline = attributes.values_at(
          :commits, :job, :pipeline
        )
        @commits ||= []
      end

      def ==(other)
        pipeline == other.pipeline &&
          job == other.job &&
          commits == other.commits
      end
    end
  end
end
