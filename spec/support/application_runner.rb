require 'rack/test'
require_relative '../../lib/plumb/server'

class ApplicationRunner
  include Rack::Test::Methods

  def start
    @app = Plumb::Server.new
  end

  def stop
  end

  def add_job(name, options)
    post "/jobs", {name: name}.merge(options)
  end

  def add_pipeline(name)
    post "/pipelines", name: name
  end

  def run_pipeline(*)
    post "/pipelines/runs"
  end

  private

  def app
    @app
  end
end
