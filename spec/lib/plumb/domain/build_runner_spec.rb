require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/build'
require_relative '../../../../lib/plumb/domain/build_runner'

module Plumb
  module Domain
    describe BuildRunner do
      it "notifies about build failure" do
        unused_job = nil
        unused_pipeline = nil

        runner = BuildRunner.new
        listener = MiniTest::Mock.new
        runner.listener = listener

        build = Build.new(unused_pipeline, unused_job)
        failure = BuildFailure.new(build)
        listener.expect(:build_failed, nil, [failure])
        runner.run_build(build)
        listener.verify
      end
    end
  end
end
