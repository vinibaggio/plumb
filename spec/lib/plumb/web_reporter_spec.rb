require 'minitest/autorun'
require_relative '../../support/spy_server'
require_relative '../../../lib/plumb/web_reporter'
require_relative '../../../lib/plumb/build_status'

module Plumb
  describe WebReporter do
    it "sends build statuses to an endpoint" do
      server = SpyServer.start(8000, '/builds/14')
      reporter = WebReporter.new("http://localhost:8000/builds")
      status = BuildStatus.new(build_id: 14,
                               status: 'success')

      reporter.build_completed(status)

      server.last_request.must_equal ['PUT', status.to_json]
    end

    it "echoes to stderr when the web server is unavailable"
  end
end

