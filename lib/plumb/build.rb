require_relative 'build_status'

module Plumb
  class Build
    def initialize(job, repo, reporter)
      @repo = repo
      @job = job
      @reporter = reporter
    end

    def run
      @repo.fetch @job.repository_url, self
    end

    def process_working_copy(dir)
      status = system("cd #{dir.path} && #{@job.script}") ? :success : :failure
      @reporter.build_completed(BuildStatus.new(status))
    end
  end
end

