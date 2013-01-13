require 'ostruct'
require_relative '../plumb'
require_relative 'job'
require_relative 'sqs_queue'

module Plumb
  class Pipeline
    class << self
      def parse(options, queue_config)
        new(order: job_order(options['order']),
            waiting_queue: waiting_queue(queue_config))
      end

      private

      def waiting_queue(config)
        Plumb.queue_driver(config).new(
          config.fetch('waiting_queue')
        )
      end

      def job_order(order)
        order.map {|step|
          step.map {|job_data|
            Job.new(
              name: job_data['name'],
              repository_url: job_data['repository_url'],
              script: job_data['script'],
            )
          }
        }
      end
    end

    attr_reader :name, :order

    def initialize(options)
      @name, @order, @waiting_queue =
        options.values_at(:name, :order, :waiting_queue)
    end

    def run
      @waiting_queue << first_job
    end

    def ==(other)
      self.name == other.name
    end

    private

    def first_job
      @order.first.first
    end
  end
end
