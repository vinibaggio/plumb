gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'yaml'
require 'pathname'
require_relative '../support/application_runner'
require_relative '../support/gmail_client'
require_relative '../support/git_repository'

require 'debugger'

describe "CI end-end" do
  let(:application) { ApplicationRunner.new }
  let(:support_path) { Pathname.new(File.expand_path('../../support/', __FILE__)) }
  let(:repository) { GitRepository.new(author: mail_config['email']) }
  let(:mail_config) { YAML.load_file(support_path.join('gmail_config.yml')) }
  let(:mail_client) { GMailClient.new(mail_config) }

  after do
    application.stop
    mail_client.logout
    repository.destroy
  end

  it "emails developers about their failed commits" do
    pipeline_name = 'myapp-deployment'

    application.start
    application.add_pipeline(pipeline_name)
    application.add_pipeline_author_emails(pipeline_name)

    repository.create
    application.add_job('unit-tests',
                        pipeline: pipeline_name,
                        script: 'rake',
                        repository_url: repository.url)
    mail_client.connect
    bad_commit_id = repository.create_bad_commit
    application.run_pipeline(pipeline_name)
    mail_client.receives_failure_notification_about_commit_id(bad_commit_id)
  end
end
