require 'minitest/autorun'
require 'yaml'
require 'securerandom'
require_relative '../../../lib/plumb/queue'

module Plumb
  describe Queue do
    THREADS = []

    let(:config) {
      YAML.load_file(File.expand_path('../../../../config/aws.yml', __FILE__))
    }

    before do
      @queues = []
    end

    after do
      THREADS << Thread.new do
        @queues.each(&:destroy)
      end
    end

    MiniTest::Unit.after_tests do
      THREADS.each(&:join)
    end

    def generate_name
      "test-#{SecureRandom.uuid}"
    end

    def item(json_string)
      Object.new.tap do |obj|
        obj.define_singleton_method(:to_json) { json_string }
        obj.define_singleton_method(:to_s) { json_string }
      end
    end

    it "pops nil when everything has been popped" do
      @queues << queue = Queue.new(generate_name, config)
      queue << item('[]')
      queue.pop
      queue.pop.must_be_nil
    end

    it "can add and pop items in a single instance" do
      @queues << queue = Queue.new(generate_name, config)
      obj = Struct.new(:to_json).new '{"foo":"bar"}'
      queue << obj
      queue.pop.must_equal obj.to_json
    end

    it "can add and pop items across instances with same name" do
      shared_name = generate_name
      @queues << queue1 = Queue.new(shared_name, config)
      @queues << queue2 = Queue.new(shared_name, config)
      obj = item('{"baz":"qux"}')
      queue1 << obj
      queue2.pop.must_equal obj.to_json
    end

    it "doesn't share queue items across instances with different names" do
      @queues << queue1 = Queue.new(generate_name, config)
      @queues << queue2 = Queue.new(generate_name, config)
      obj = item('{"baz":"qux"}')
      queue1 << obj
      queue2.pop.must_be_nil
    end

    it "can enqueue the direct output of another queue" do
      @queues << queue1 = Queue.new(generate_name, config)
      @queues << queue2 = Queue.new(generate_name, config)
      obj = item('{"baz":"qux"}')
      queue1 << obj
      queue2 << queue1.pop
      queue2.pop.must_equal '{"baz":"qux"}'
    end

    it "returns multiple queued items" do
      @queues << queue = Queue.new(generate_name, config)
      item1 = item('{"baz":"qux"}')
      item2 = item('{"bar":"foo"}')
      queue << item1
      queue << item2

      expected_items = [item1, item2]

      tries = 0
      until expected_items.empty? || (tries += 1) == 5 do
        message = queue.pop
        expected_items.delete_if {|item| item.to_json == message.to_json}
      end

      expected_items.must_be_empty
    end

    it "allows access to message properties" do
      @queues << queue = Queue.new(generate_name, config)
      obj = item('{"baz":"qux"}')
      queue << obj
      queue.pop['baz'].must_equal 'qux'
    end
  end
end

