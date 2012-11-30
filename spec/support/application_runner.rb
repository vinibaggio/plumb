require 'hooves/unicorn'
require_relative '../../lib/plumb/server'

class ApplicationRunner
  def start
    @pid = fork do
      Hooves::Unicorn.run Plumb::Server.new, Port: 9876
    end
  end

  def stop
    Process.kill('TERM', @pid)
    Process.wait
  end

  def add_job(*)
  end

  def add_pipeline(*)
  end

  def run_pipeline(*)
  end
end
