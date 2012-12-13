require 'minitest/autorun'
require 'yaml'
require_relative '../../../../lib/plumb/infrastructure/queue'
require_relative '../../../../lib/plumb/domain/job'

module Plumb
  module Infrastructure
    describe Queue do
      let(:config) { YAML.load_file(File.expand_path('../../../../../config/aws.yml', __FILE__)) }
      let(:klass) { Struct.new(:to_json) }

      it "pops nil when everything has been popped" do
        queue = Infrastructure::Queue.new('bob', config)
        queue << klass.new('[]')
        queue.pop
        queue.pop.must_be_nil
      end

      it "can add and pop items in a single instance" do
        queue = Infrastructure::Queue.new('foo', config)
        queue.clear
        job = klass.new '{"foo":"bar"}'
        queue << job
        queue.pop.must_equal job.to_json
      end

      it "can add and pop items across instances with same name" do
        queue1 = Infrastructure::Queue.new('bar', config)
        queue1.clear
        queue2 = Infrastructure::Queue.new('bar', config)
        queue2.clear
        job = klass.new('{"baz":"qux"}')
        queue1 << job
        queue2.pop.must_equal job.to_json
      end

      it "doesn't share queue items across instances with different names" do
        queue1 = Infrastructure::Queue.new('foo', config)
        queue1.clear
        queue2 = Infrastructure::Queue.new('bar', config)
        queue2.clear
        job = klass.new('{"baz":"qux"}')
        queue1 << job
        queue2.pop.must_be_nil
      end

      it "can enqueue the direct output of another queue" do
        queue1 = Infrastructure::Queue.new('foo', config)
        queue1.clear
        queue2 = Infrastructure::Queue.new('bar', config)
        queue2.clear
        job = klass.new('{"baz":"qux"}')
        queue1 << job
        queue2 << queue1.pop
        queue2.pop.must_equal '{"baz":"qux"}'
      end

      it "returns multiple queued jobs" do
        queue = Infrastructure::Queue.new('foo', config)
        queue.clear
        job1 = klass.new('{"baz":"qux"}')
        job2 = klass.new('{"bar":"foo"}')
        queue << job1
        queue << job2
        queue.pop.must_equal job1.to_json
        queue.pop.must_equal job2.to_json
      end

      it "allows access to message properties" do
        queue = Infrastructure::Queue.new('foo', config)
        queue.clear
        job = klass.new('{"baz":"qux"}')
        queue << job
        queue.pop['baz'].must_equal 'qux'
      end
    end
  end
end

