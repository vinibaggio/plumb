require 'minitest/autorun'
require 'yaml'
require 'pathname'
require 'tmpdir'
require_relative '../support/pipeline_processor_driver'
require_relative '../support/queue_runner_driver'
require_relative '../support/gmail_client'
require_relative '../support/git_repository'

describe "CI end-end" do
  let(:pipeline_processor) { PipelineProcessorDriver.new }
  let(:waiting_queue_runner) { QueueRunnerDriver.new('pipeline-waiting-queue-runner') }
  let(:immediate_queue_runner) { QueueRunnerDriver.new('pipeline-immediate-queue-runner') }
  let(:support_path) { Pathname.new(File.expand_path('../../support/', __FILE__)) }
  let(:repository) { GitRepository.new(author: mail_config['email']) }
  let(:mail_config) { YAML.load_file(support_path.join('gmail_config.yml')) }
  let(:mail_client) { GMailClient.new(mail_config) }

  after do
    mail_client.logout
    repository.destroy
    waiting_queue_runner.stop
    immediate_queue_runner.stop
  end

  it "runs a build successfully" do
    tmpdir = Dir.mktmpdir
    tmppath = "#{tmpdir}/foo"

    waiting_queue_runner.start
    immediate_queue_runner.start

    pipeline_processor.add_pipeline('myapp-deployment')

    repository.create
    pipeline_processor.add_job('unit-tests',
                               pipeline: 'myapp-deployment',
                               script: "echo 'success' > #{tmppath}",
                               repository_url: repository.url)
    pipeline_processor.run_pipeline('myapp-deployment')

    tries = 0
    while !File.exists?(tmppath) && tries < 5
      tries += 1
      sleep 1
    end
    File.read(tmppath).strip.must_equal 'success'
  end

  #it "sends an email to a configured address when a build fails" do
    #pipeline_processor.start
    #pipeline_processor.add_pipeline('myapp-deployment')
    #pipeline_processor.add_pipeline_notification_emails(
      #'myapp-deployment', mail_config['email']
    #)

    #repository.create
    #pipeline_processor.add_job('unit-tests',
                        #pipeline:'myapp-deployment',
                        #script: 'rake',
                        #repository_url: repository.url)
    #mail_client.connect
    #bad_commit_id = repository.create_bad_commit
    #pipeline_processor.run_pipeline('myapp-deployment')
    #mail_client.receives_failure_notification_about_commit_ids(
      #[bad_commit_id]
    #)
  #end
end
