require 'ostruct'
require_relative 'job'
require_relative '../infrastructure/queue'

module Plumb
  module Domain
    class Pipeline
      class << self
        def parse(options)
          new(
            waiting_queue: Infrastructure::Queue.new('pipeline-waiting-queue'),
            notification_email: options['notification_email'],
            order: options['order'].map {|step|
              step.map {|job_data|
                Job.new(
                  name: job_data['name'],
                  repository_url: job_data['repository_url'],
                  script: job_data['script'],
                )
              }
            }
          )
        end
      end

      attr_reader :name, :notification_email, :order

      def initialize(options)
        @name, @order, @waiting_queue = options.values_at(
          :name, :order, :waiting_queue
        )
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
end
