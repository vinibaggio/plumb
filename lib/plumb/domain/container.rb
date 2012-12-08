module Plumb
  module Domain
    class Container
      def initialize(klass, listener, storage)
        @klass = klass
        @listener = listener
        @storage = storage
      end

      def <<(object)
        @storage[object.name] = object
        @listener.__send__("#{human_type}_created", object)
      end

      def fetch(name)
        find_entity(name) do |pipeline|
          @listener.__send__("#{human_type}_found", pipeline)
        end
      end

      def update(name, attributes)
        find_entity(name) do |pipeline|
          self << @klass.new(pipeline.attributes.merge(attributes))
        end
      end

      private

      def find_entity(name)
        found(name).tap do |pipeline|
          yield pipeline if pipeline
        end
      end

      def found(name)
        @storage.fetch(name) do
          @listener.__send__("#{human_type}_not_found", name)
        end
      end

      def human_type
        @klass.name.split('::').last.downcase
      end
    end
  end
end
