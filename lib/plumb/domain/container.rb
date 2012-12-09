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
        find_entity(name) do |entity|
          @listener.__send__("#{human_type}_found", entity)
        end
      end

      def update(name, attributes)
        find_entity(name) do |entity|
          self << @klass.new(entity.attributes.merge(attributes))
        end
      end

      private

      def find_entity(name)
        found(name).tap do |entity|
          yield entity if entity
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
