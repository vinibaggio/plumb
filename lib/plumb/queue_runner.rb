module Plumb
  class QueueRunner
    def initialize(queue, post_yield_callable)
      @queue = queue
      @post_yield_callable = post_yield_callable
    end

    def run
      item = @queue.pop
      yield item if item
      @post_yield_callable.call
    end
  end
end
