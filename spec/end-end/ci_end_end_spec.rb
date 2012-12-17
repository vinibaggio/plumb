require 'minitest/autorun'
require 'pathname'
require_relative '../support/pipeline_processor_driver'
require_relative '../support/queue_runner_driver'
require_relative '../support/git_repository'
require_relative '../support/web_application_driver'

describe "CI end-end" do
  let(:web_app) { WebApplicationDriver.new }
  let(:pipeline_processor) { PipelineProcessorDriver.new }
  let(:waiting_queue_runner) { QueueRunnerDriver.new('pipeline-waiting-queue-runner') }
  let(:immediate_queue_runner) { QueueRunnerDriver.new('pipeline-immediate-queue-runner') }
  let(:repository) { GitRepository.new }
  let(:services) { [ waiting_queue_runner, immediate_queue_runner, web_app ] }

  after do
    repository.destroy
    services.reverse.each(&:stop)
  end

  it "shows a single green build in the feed" do
    services.each(&:start)
    repository.create
    repository.create_good_commit
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
    services.each(&:start)
    repository.create
    repository.create_bad_commit
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
end
