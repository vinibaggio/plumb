module Plumb
  autoload :SqsQueue, File.expand_path('../plumb/sqs_queue', __FILE__)
  autoload :ResqueQueue, File.expand_path('../plumb/resque_queue', __FILE__)

  class << self
    def queue_driver(config)
      const_get(config.fetch('driver'))
    end
  end
end
