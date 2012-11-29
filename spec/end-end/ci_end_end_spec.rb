gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'yaml'
require_relative 'gmail_client'

describe "CI end-end" do
  let(:application) { ApplicationRunner.new }
  let(:repository_url) { 'https://github.com/camelpunch/ci_test_repo.git' }
  let(:repository) {
    Repository.new(committer: gmail_config['email'],
                   url: repository_url)
  }
  let(:gmail_config) { YAML.load_file(File.expand_path('../gmail_config.yml', __FILE__)) }
  let(:mail_client) { GMailClient.new(gmail_config) }

  after do
    application.stop
    mail_client.logout
  end

  it "emails developers about their failed commits (assuming one-commit-per-push)" do
    application.start
    application.add_job(job_name: 'unit-tests',
                        script: 'rake',
                        repository: repository_url)

    mail_client.connect
    bad_commit_id = repository.push_bad_commit
    mail_client.receives_failure_notification_about_commit_id(bad_commit_id)
  end

  class ApplicationRunner
    def start
      # load up the server - rack?
    end

    def stop
    end

    def add_job(*)
      # some capybara stuff
    end
  end

  class Repository
    def initialize(options)
    end

    def push_bad_commit
    end
  end
end
