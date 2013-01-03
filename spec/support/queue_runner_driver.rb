require_relative '../../lib/plumb/sqs_queue'

module SpecSupport
  class QueueRunnerDriver
    def initialize(queue_name, config_path)
      @cmd_path = File.expand_path(
        "../../../bin/plumb-#{queue_name}",
        __FILE__
      )
      @config_path = config_path
    end

    def start
      @pid = Process.spawn("#{@cmd_path} #{@config_path}",
                           :out => '/dev/null',
                           :err => '/dev/null')
    end

    def stop
      Process.kill('KILL', @pid) if @pid
    rescue Errno::ESRCH
    end
  end
end
