module Plumb
  module UI
    class CliTranslator
      def initialize(listener, verbs_to_nouns)
        @listener = listener
        @verbs_to_nouns = verbs_to_nouns
      end

      def process_command(args)
        @listener.__send__ *Event.new(args, @verbs_to_nouns)
      end

      class Event < Struct.new(:args, :verbs_to_nouns)
        def to_a
          return [:unknown_command, args.join(' ')] if invalid?
          [name(entity, verb)] +
            [first_arg, second_arg, complex_arg(5)].compact
        end

        def invalid?
          ! (entity && verbs_to_nouns[verb])
        end

        def first_arg
          simple_command? ? args[2] : args[1]
        end

        def second_arg
          simple_command? ? args[3] : args[4]
        end

        def complex_arg(idx)
          args[idx] if complex_command?
        end

        def verb
          simple_command? ? args[1] : args[3]
        end

        def entity
          simple_command? ? args[0] : [args[0], args[2]].join('_')
        end

        def simple_command?
          verbs_to_nouns.keys.include?(args[1])
        end

        def complex_command?
          ! simple_command?
        end

        def name(entity, verb)
          "#{entity}_#{verbs_to_nouns[verb]}_requested".to_sym
        end
      end
    end
  end
end
