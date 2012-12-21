require 'minitest/autorun'
require 'thread'
require_relative '../../../../lib/plumb/infrastructure/queue_runner'
require_relative '../../../../lib/plumb/domain/job'
module Plumb
  module Infrastructure
    describe QueueRunner do
      it "passes each job popped to a given block of code" do
        runner = Infrastructure::QueueRunner.new(
          queue = Queue.new, ->{},
        )
        queue << job1 = Domain::Job.new(name: 'job1')
        queue << job2 = Domain::Job.new(name: 'job2')
        queue << job3 = Domain::Job.new(name: 'job3')
        queue << job4 = Domain::Job.new(name: 'job4')
        queue << job5 = Domain::Job.new(name: 'job5')

        jobs_passed = []
        queue.size.times do
          runner.run do |job|
            jobs_passed << job
          end
        end

        jobs_passed.must_equal [job1, job2, job3, job4, job5]
        queue.must_be_empty
      end

      it "calls the post-processing callable after yielding" do
        runner = Infrastructure::QueueRunner.new(
          queue = Queue.new,
          callable = MiniTest::Mock.new
        )
        queue << Domain::Job.new(name: 'foo')

        callable.expect(:call, nil, [])
        runner.run do |job| end
        callable.verify
      end

      it "doesn't yield nil jobs" do
        runner = Infrastructure::QueueRunner.new(
          queue = Queue.new, ->{},
        )
        queue << nil

        called = false
        runner.run do |job|
          called = true
        end
        called.must_equal false
      end
    end
  end
end

