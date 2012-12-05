require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/build'

module Plumb
  module Domain
    describe Build do
      it "has getters for its attributes" do
        pipeline = Object.new
        job = Object.new

        Build.new(
          pipeline: pipeline,
          job: job,
          commits: ['asdf', 'asdf']
        ).tap do |build|
          build.pipeline.must_equal pipeline
          build.job.must_equal job
          build.commits.must_equal ['asdf', 'asdf']
        end
      end

      it "defaults to having empty commits" do
        Build.new(
          pipeline: Pipeline.new,
          job: Job.new
        ).commits.must_be :empty?
      end

      it "is equal to a build with same attributes" do
        Build.new.must_equal Build.new
      end
    end
  end
end
