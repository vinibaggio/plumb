require 'minitest/autorun'
require 'pathname'
require_relative '../support/pipeline_processor_driver'
require_relative '../support/queue_runner_driver'
require_relative '../support/git_repository'

describe "CI end-end" do
  class WebApplicationDriver
    def start
    end

    def stop
    end

    def shows_green_build_xml_for(*)
      raise NotImplementedError
    end
  end

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
end
