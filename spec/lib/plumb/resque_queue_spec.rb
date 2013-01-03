require 'minitest/autorun'
require 'yaml'
require 'securerandom'
require_relative '../../../lib/plumb/resque_queue'
require_relative '../../support/shared_examples/queues.rb'

module Plumb
  class ResqueQueueSpec < QueueSpec
    def queue_named(name)
      ResqueQueue.new(name)
    end
  end
end

