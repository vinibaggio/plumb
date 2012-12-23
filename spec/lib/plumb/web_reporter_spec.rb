require 'minitest/autorun'
require 'thread'
require 'webrick'
require 'tempfile'
require 'json'
require_relative '../../../lib/plumb/web_reporter'
require_relative '../../../lib/plumb/build_status'

module Plumb
  describe WebReporter do
    it "sends build statuses to an endpoint" do
      server = SpyServer.start(8000, '/builds/14')
      reporter = WebReporter.new("http://localhost:8000/builds")
      status = BuildStatus.new(14, 'success')

      reporter.build_completed(status)

      server.last_request.must_equal ['PUT', status.to_json ]
    end

    class SpyServer
      class << self
        attr_accessor :queue

        def start(port, path)
          new(port, path).tap(&:start)
        end
      end

      def initialize(port, path)
        @port = port
        @path = path
        SpyServer.queue = ::Queue.new
      end

      def start
        server.mount(@path, PutServlet)
        Thread.new { server.start }.abort_on_exception = true
      end

      def last_request
        SpyServer.queue.pop(non_block = true)
      end

      private

      def server
        @server ||= WEBrick::HTTPServer.new(Port: @port)
      end

      class PutServlet < WEBrick::HTTPServlet::AbstractServlet
        def do_PUT(request, _)
          SpyServer.queue << [request.request_method, request.body]
        end
      end
    end
  end
end

