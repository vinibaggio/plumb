require 'nokogiri'
require 'httparty'
require_relative '../../web/server'

module SpecSupport
  class WebApplicationDriver
    class Server
      include HTTParty
      base_uri 'localhost:4567'
    end

    def start
      @pid = Process.spawn("web/server.rb",
                           :out => $stdout,
                           :err => $stderr)
      until server_is_up? do sleep 0.5 end
    end

    def stop
      Process.kill('KILL', @pid) if @pid
    rescue Errno::ESRCH
    end

    def clear
      Server.delete("/jobs/all")
    end

    def shows_green_build_xml_for(project_name)
      sleep 5
      project(project_name)['activity'].must_equal 'Sleeping'
      project(project_name)['lastBuildStatus'].must_equal 'Success'
    end

    def shows_red_build_xml_for(project_name)
      sleep 5
      project(project_name)['activity'].must_equal 'Sleeping'
      project(project_name)['lastBuildStatus'].must_equal 'Failure'
    end

    private

    def server_is_up?
      Server.get("/jobs")
      true
    rescue Errno::ECONNREFUSED
      false
    rescue Errno::ECONNRESET
      false
    end

    def project(name)
      feed.css("Projects>Project[name='#{name}']").first
    end

    def feed
      response = Server.get("/dashboard/cctray.xml")
      Nokogiri::XML(response.body)
    end
  end
end
