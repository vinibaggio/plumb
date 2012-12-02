require_relative '../../../spec_helper'
require_relative '../../../../lib/plumb/ui/cli_translator'

module Plumb
  module UI
    describe CliTranslator do
      let(:no_parser) { nil }
      let(:no_verb_mapping) { {} }
      let(:listener) { MiniTest::Mock.new }

      after do
        listener.verify
      end

      it "notifies about unknown command" do
        command = %w(create)
        translator = CliTranslator.new(listener, no_verb_mapping)
        listener.expect(:unknown_command, nil, ['create'])
        translator.process_command(command)
      end

      it "doesn't barf on long commands" do
        command = %w(do something very long and complicated please)
        translator = CliTranslator.new(listener, no_verb_mapping)
        listener.expect(:unknown_command, nil,
                        ['do something very long and complicated please'])
        translator.process_command(command)
      end

      it "notifies about top-level entity creation" do
        command = %w(pipeline create test_rig)
        translator = CliTranslator.new(listener, 'create' => 'creation')
        listener.expect(:pipeline_creation_requested, nil, ['test_rig'])
        translator.process_command(command)
      end

      it "notifies about top-level entity creation with an argument" do
        command = %w(job create unit_tests git@github.com:camelpunch/somerepo)
        translator = CliTranslator.new(listener, 'create' => 'creation')
        listener.expect(:job_creation_requested, nil,
                        ['unit_tests', 'git@github.com:camelpunch/somerepo'])
        translator.process_command(command)
      end

      it "notifies about setting up a service on an existing entity" do
        command = %w(pipeline myapp-deployment author_email_notification create)
        translator = CliTranslator.new(listener, 'create' => 'creation')
        listener.expect(
          :pipeline_author_email_notification_creation_requested,
          nil,
          ['myapp-deployment']
        )
        translator.process_command(command)
      end

      it "notifies about appending an entity to an entity" do
        command = %w(pipeline test_rig job append unit_tests)
        translator = CliTranslator.new(listener, 'append' => 'append')
        listener.expect(:pipeline_job_append_requested, nil,
                        ['test_rig', 'unit_tests'])
        translator.process_command(command)
      end

      it "notifies about creating an entity on an entity with two args" do
        command = %w(job unit_tests script create run_rake 'rake')
        translator = CliTranslator.new(listener, 'create' => 'creation')
        listener.expect(:job_script_creation_requested, nil,
                        ['unit_tests', 'run_rake', "'rake'"])
        translator.process_command(command)
      end
    end
  end
end
