module Plumb
  module Domain
    class PipelineRunner
      attr_writer :pipeline_fetcher, :job_fetcher

      def initialize(pipeline_name, build_runner)
        @pipeline_name = pipeline_name
        @build_runner = build_runner
      end

      def run
        @pipeline_fetcher.fetch(@pipeline_name)
      end

      def pipeline_found(pipeline)
        @pipeline = pipeline
        @job_fetcher.fetch(pipeline.order.first.first)
      end

      def job_found(job)
        raise "No commits" if job.repository.commits.nil?
        @build_runner.run_build(
          Build.new(pipeline: @pipeline, job: job,
                    commits: [job.repository.commits.first])
        )
      end
    end
  end
end

