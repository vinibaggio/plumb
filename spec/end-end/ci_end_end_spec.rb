require 'minitest/autorun'
require 'pathname'
require_relative '../support/pipeline_processor_driver'
require_relative '../support/queue_runner_driver'
require_relative '../support/git_repository'
require_relative '../support/web_application_driver'

describe "CI end-end" do
  let(:web_app) { SpecSupport::WebApplicationDriver.new }
  let(:pipeline_processor) { SpecSupport::PipelineProcessorDriver.new }
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
  let(:repository) { SpecSupport::GitRepository.new }
  let(:queue_runners) { [ waiting_queue_runner, immediate_queue_runner ] }

  after do
    repository.destroy
    web_app.stop
    queue_runners.each(&:stop)
  end

  it "shows a single green build in the feed" do
    web_app.start
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
    web_app.start
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
end
