module Plumb
  module UI
    class CliTranslator
      def initialize(listener)
        @listener = listener
      end

      def process_command(args)
        @listener.__send__(*Command.new(args).sendable)
      end

      class Command
        def initialize(args)
          @all_args = args.clone
          @name, @entity, @verb, @arg = args.slice!(0..3)
        end

        def sendable
          if valid?
            [event, @arg]
          else
            [:unknown_command, @all_args.join(' ')]
          end
        end

        private

        def event
          "#{@entity}_#{noun}_requested".to_sym
        end

        def noun
          'creation' if @verb == 'create'
        end

        def valid?
          !! @entity && noun
        end
      end
    end
  end
end
