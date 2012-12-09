require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/domain/build'

module Plumb
  module Domain
    describe Pipeline do
      it "is equivalent to another pipeline with the same name" do
        Pipeline.new(name: 'foo').must_equal(
          Pipeline.new(name: 'foo', order: [])
        )
      end

      it "is not equivalent to another pipeline with different name" do
        Pipeline.new(name: 'bar').wont_equal(
          Pipeline.new(name: 'foo')
        )
      end

      it "queues the first job when run" do
        job1 = Object.new
        job2 = Object.new
        queue = Minitest::Mock.new
        pipeline = Pipeline.new(
          queue: queue,
          order: [[job1], [job2]]
        )
        queue.expect(:<<, nil, [job1])
        pipeline.run
        queue.verify
      end
    end
  end
end

