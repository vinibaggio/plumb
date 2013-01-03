require 'minitest/autorun'
require 'yaml'
require 'securerandom'
require_relative '../../../lib/plumb/sqs_queue'
require_relative '../../support/shared_examples/queues.rb'

module Plumb
  class SqsQueueSpec < QueueSpec
    def queue_named(name)
      SqsQueue.new(
        name,
        YAML.load_file(
          File.expand_path('../../../../config/aws.yml', __FILE__)
        )
      )
    end
  end
end

