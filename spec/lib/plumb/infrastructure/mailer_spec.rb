require 'minitest/autorun'
require_relative '../../../support/gmail_client'
require_relative '../../../../lib/plumb/infrastructure/mailer'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/build'
require_relative '../../../../lib/plumb/domain/build_failure'

module Plumb
  module Infrastructure
    describe Mailer do
      let(:root_path) { Pathname.new(File.expand_path('../../../../..', __FILE__)) }
      let(:config_path) { root_path.join('config') }
      let(:support_path) { root_path.join('spec', 'support') }
      let(:mail_config_test) { YAML.load_file(support_path.join('gmail_config.yml')) }
      let(:mail_config_production) { YAML.load_file(config_path.join('mail.yml')) }
      let(:aws_config) { YAML.load_file(config_path.join('aws.yml')) }
      let(:mail_client) { GMailClient.new(mail_config_test) }

      after do
        mail_client.logout
      end

      describe "build failure" do
        it "raises if the build has no notification address" do
          pipeline = Domain::Pipeline.new(
            name: 'test-all',
            notification_email: nil
          )

          ->{
            Mailer.new(mail_config_production, aws_config).build_failed(
              Domain::BuildFailure.new(
                Domain::Build.new(pipeline: pipeline,
                                  job: Domain::Job.new,
                                  commits: ['1234', 'asdf'])
              )
            )
          }.must_raise Mailer::NoRecipients
        end

        it "sends an email to the configured address" do
          email = mail_config_test['email']
          pipeline = Domain::Pipeline.new(
            name: 'test-all',
            notification_email: email
          )

          mail_client.connect
          Mailer.new(mail_config_production, aws_config).build_failed(
            Domain::BuildFailure.new(
              Domain::Build.new(pipeline: pipeline,
                                job: Domain::Job.new,
                                commits: ['1234', 'asdf'])
            )
          )
          mail_client.receives_failure_notification_about_commit_ids(
            ['asdf', '1234']
          )
        end
      end
    end
  end
end

