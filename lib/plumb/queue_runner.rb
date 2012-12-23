require_relative 'job'

module Plumb
  class QueueRunner
    def initialize(queue, callable_when_empty)
      @queue = queue
      @callable_when_empty = callable_when_empty
    end

    def run
      message = @queue.pop
      if message
        job = Job.new(message.attributes)
        yield job
      else
        @callable_when_empty.call
      end
    end
  end
end
