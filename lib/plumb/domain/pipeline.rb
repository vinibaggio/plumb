require 'ostruct'
require_relative 'job'

module Plumb
  module Domain
    class Pipeline
      class << self
        def parse(options)
          new(
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
        @name, @order, @queue = options.values_at(
          :name, :order, :queue
        )
      end

      def run
        @queue << first_job
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
