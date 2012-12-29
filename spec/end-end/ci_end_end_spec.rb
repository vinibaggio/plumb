require 'minitest/autorun'
require 'pathname'
require 'securerandom'
require_relative '../support/pipeline_processor_driver'
require_relative '../support/queue_runner_driver'
require_relative '../support/git_repository'
require_relative '../support/web_application_driver'

describe "CI end-end" do
  let(:web_app) { SpecSupport::WebApplicationDriver.new }
  let(:pipeline_processor) { SpecSupport::PipelineProcessorDriver.new(config_path) }
  let(:config_path) {
    File.expand_path('../../support/queue_config.json', __FILE__)
  }
  let(:waiting_queue_runner) {
    SpecSupport::QueueRunnerDriver.new(
      'pipeline-waiting-queue-runner',
      config_path
    )
  }
  let(:immediate_queue_runner) { 
    SpecSupport::QueueRunnerDriver.new(
      'pipeline-immediate-queue-runner',
      config_path
    )
  }
  let(:queue_suffix) { SecureRandom.uuid }
  let(:repository) { SpecSupport::GitRepository.new }
  let(:queue_runners) { [waiting_queue_runner, immediate_queue_runner] }

  before do
    write_new_queue_config
  end

  after do
    repository.destroy
    web_app.stop
    queue_runners.each(&:stop)
    delete_queues
  end

  it "shows a single green build in the feed" do
    web_app.start.with_no_data

    repository.create
    repository.create_good_commit
    queue_runners.each(&:start)
    pipeline_processor.run_pipeline(
      order: [
        [
          {
            name: 'unit-tests',
            repository_url: repository.url,
            script: 'rake'
          }
        ]
      ]
    )
    web_app.shows_green_build_xml_for('unit-tests')
  end

  it "shows a single red build in the feed" do
    web_app.start.with_no_data

    repository.create
    repository.create_bad_commit
    queue_runners.each(&:start)
    pipeline_processor.run_pipeline(
      order: [
        [
          {
            name: 'unit-tests',
            repository_url: repository.url,
            script: 'rake'
          }
        ]
      ]
    )
    web_app.shows_red_build_xml_for('unit-tests')
  end

  it "shows builds in progress in the feed"

  def delete_queues
    %w(waiting_queue immediate_queue).each do |name|
      Plumb::Queue.new(
        JSON.parse(File.read(config_path))[name]
      ).destroy
    end
  rescue AWS::SQS::Errors::QueueDeletedRecently
  end

  def write_new_queue_config
    File.open(config_path, 'w') do |file|
      file << JSON.generate(
        immediate_queue: "pipeline-immediate-queue-#{queue_suffix}",
        waiting_queue: "pipeline-waiting-queue-#{queue_suffix}",
        build_status_endpoint: "http://localhost:4567/builds"
      )
    end
  end
end
