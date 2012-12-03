require 'set'

module Plumb
  module Domain
    class Pipelines
      def initialize(listener, storage)
        @listener = listener
        @pipelines = storage
      end

      def <<(pipeline)
        @pipelines << pipeline
        @listener.pipeline_created(pipeline)
      end

      def fetch(name)
        find_pipeline(name) do |pipeline|
          @listener.pipeline_found(pipeline)
        end
      end

      def update(name, attributes)
        find_pipeline(name) do |pipeline|
          self << Pipeline.new(pipeline.attributes.merge(attributes))
          @pipelines.delete(pipeline)
        end
      end

      private

      def find_pipeline(name)
        pipeline = @pipelines.find ->{ @listener.pipeline_not_found(name) } {|pipeline|
          pipeline.name == name
        }

        yield pipeline if pipeline
      end
    end
  end
end
