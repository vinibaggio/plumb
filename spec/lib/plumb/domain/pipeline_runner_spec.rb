require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/pipeline_runner'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/script'
require_relative '../../../../lib/plumb/domain/build'

module Plumb
  module Domain
    describe PipelineRunner do
      it "fetches the named pipeline" do
        unused_build_runner = nil
        pipeline_fetcher = Minitest::Mock.new
        pipeline_runner = PipelineRunner.new('build-everything',
                                             unused_build_runner)
        pipeline_runner.pipeline_fetcher = pipeline_fetcher
        pipeline_fetcher.expect(:fetch, nil, ['build-everything'])
        pipeline_runner.run
        pipeline_fetcher.verify
      end

      it "fetches the pipeline's first job when pipeline found" do
        unused_build_runner = nil
        job_fetcher = Minitest::Mock.new
        pipeline_runner = PipelineRunner.new('build-everything',
                                             unused_build_runner)
        pipeline_runner.job_fetcher = job_fetcher

        pipeline = Pipeline.new(name: 'foo', order: [['myjob']])
        job_fetcher.expect(:fetch, nil, ['myjob'])
        pipeline_runner.pipeline_found(pipeline)
        job_fetcher.verify
      end

      it "runs a build when the job is found" do
        unused_job_fetcher = Object.new
        def unused_job_fetcher.fetch(*); end

        build_runner = Minitest::Mock.new
        pipeline_runner = PipelineRunner.new('build-everything',
                                             build_runner)
        pipeline_runner.job_fetcher = unused_job_fetcher

        pipeline = Pipeline.new(name: 'foo', order: [['myjob']])
        job = Job.new(name: 'myjob', script: Script.new('tests', 'rake'))

        pipeline_runner.pipeline_found(pipeline)
        build_runner.expect(
          :run_build, nil,
          [Build.new(pipeline: pipeline, job: job)]
        )
        pipeline_runner.job_found(job)
        build_runner.verify
      end
    end
  end
end
