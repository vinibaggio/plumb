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
                           :out => '/dev/null',
                           :err => '/dev/null')
      probe_until('server up') { server_is_up? }
      self
    end

    def stop
      Process.kill('KILL', @pid) if @pid
    rescue Errno::ESRCH
    ensure
      self
    end

    def with_no_data
      Server.delete("/jobs/all")
      self
    end

    def shows_green_build_xml_for(project_name)
      probe_until('green build available in feed') { project(project_name) }
      project(project_name)['activity'].must_equal 'Sleeping',
        feed
      project(project_name)['lastBuildStatus'].must_equal 'Success',
        feed
    end

    def shows_red_build_xml_for(project_name)
      probe_until('red build available in feed') { project(project_name) }
      project(project_name)['activity'].must_equal 'Sleeping'
      project(project_name)['lastBuildStatus'].must_equal 'Failure'
    end

    private

    def server_is_up?
      Server.get("/dashboard/cctray.xml")
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

    def probe_until(description, &block)
      #puts "----- Probe until #{description}"
      tries = 0
      value = nil

      until (value = yield) || tries == 10 do
        #puts "-- Got value: #{value}"
        tries += 1
        sleep 0.5
      end

      message =
        "-- Probing until '#{description}' reached its limit\n\n" +
        "-- Last value: #{value}\n\n"

      if tries == 10
        $stderr.puts message
      end
    end
  end
end
