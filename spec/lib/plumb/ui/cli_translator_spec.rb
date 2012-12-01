gem 'minitest'
require 'minitest/spec'
require 'minitest/mock'
require_relative '../../../../lib/plumb/ui/cli_translator'

module Plumb
  module UI
    describe CliTranslator do
      let(:listener) { MiniTest::Mock.new }

      after do
        listener.verify
      end

      describe "sending unknown commands" do
        it "notifies about the unknown command" do
          command = %w(plumb)
          translator = CliTranslator.new(listener)

          listener.expect(:unknown_command, nil, %w(plumb))
          translator.process_command(command)
        end

        it "doesn't barf on long commands" do
          command = %w(plumb and do something very long and complicated)
          translator = CliTranslator.new(listener)

          listener.expect(:unknown_command, nil, ['plumb and do something very long and complicated'])
          translator.process_command(command)
        end
      end

      describe "creating a pipeline" do
        it "notifies about a create pipeline event" do
          command = %w(plumb pipeline create test_rig)
          translator = CliTranslator.new(listener)
          listener.expect(:pipeline_creation_requested, nil, %w(test_rig))
          translator.process_command(command)
        end
      end
    end
  end
end
