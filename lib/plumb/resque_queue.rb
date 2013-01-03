require 'resque'
require_relative 'message'

module Plumb
  class ResqueQueue
    def initialize(name)
      @queue_name = name
    end

    def <<(item)
      Resque::Job.create(@queue_name, 'Plumb::ResqueQueue', [item])
    end

    def pop
      job = Resque.pop(@queue_name)
      return nil unless job
      Plumb::Message.new(convert(job))
    end

    def destroy
      Resque.remove_queue(@queue_name)
    end

    private

    def convert(job)
      job && JSON.generate(job['args'].first.first)
    end
  end
end
