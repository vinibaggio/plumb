class QueueRunnerDriver
  def initialize(queue_name)
    @cmd_path = File.expand_path(
      "../../../bin/plumb-#{queue_name}",
      __FILE__
    )
  end

  def start
    @pid = Process.spawn(@cmd_path,
                         :out => $stdout,
                         :err => $stderr)
  end

  def stop
    Process.kill('KILL', @pid) if @pid
  end
end
