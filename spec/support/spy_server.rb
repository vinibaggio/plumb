require 'thread'
require 'webrick'
require 'tempfile'
require 'json'

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
    @server ||= WEBrick::HTTPServer.new(
      Port: @port,
      AccessLog: [],
      Logger: WEBrick::Log.new('/dev/null', 7)
    )
  end

  class PutServlet < WEBrick::HTTPServlet::AbstractServlet
    def do_PUT(request, _)
      SpyServer.queue << [request.request_method, request.body]
    end
  end
end

