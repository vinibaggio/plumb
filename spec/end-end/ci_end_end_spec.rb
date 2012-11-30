gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'yaml'
require_relative '../support/application_runner'
require_relative '../support/gmail_client'
require_relative '../support/git_repository'

describe "CI end-end" do
  let(:application) { ApplicationRunner.new }
  let(:repository_url) { 'https://github.com/camelpunch/ci_test_repo.git' }
  let(:repository) {
    GitRepository.new(committer: mail_config['email'],
                      url: repository_url)
  }
  let(:mail_config) {
    YAML.load_file(File.expand_path('../../support/gmail_config.yml', __FILE__))
  }
  let(:mail_client) { GMailClient.new(mail_config) }

  after do
    application.stop
    mail_client.logout
  end

  it "emails developers about their failed commits" do
    pipeline_name = 'myapp-deployment'

    application.start
    application.add_pipeline(pipeline_name)
    application.add_job('unit-tests',
                        pipeline: pipeline_name,
                        script: 'rake',
                        repository: repository_url)
    mail_client.connect
    bad_commit_id = repository.push_bad_commit(author: mail_config['email'])
    application.run_pipeline(pipeline_name)
    mail_client.receives_failure_notification_about_commit_id(bad_commit_id)
  end
end
