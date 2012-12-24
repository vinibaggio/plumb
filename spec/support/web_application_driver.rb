require 'nokogiri'
require 'httparty'
require_relative '../../web/server'

module SpecSupport
  class WebApplicationDriver
    def start
      @pid = Process.spawn("web/server.rb",
                           :out => $stdout,
                           :err => $stderr)
    end

    def stop
      Process.kill('KILL', @pid) if @pid
    rescue Errno::ESRCH
    end

    def shows_green_build_xml_for(project_name)
      sleep 2
      project(project_name)['activity'].must_equal 'Sleeping'
      project(project_name)['lastBuildStatus'].must_equal 'Success'
    end

    def shows_red_build_xml_for(project_name)
      sleep 2
      project(project_name)['activity'].must_equal 'Sleeping'
      project(project_name)['lastBuildStatus'].must_equal 'Failure'
    end

    private

    def project(name)
      feed.css("Projects>Project[name='#{name}']").first
    end

    def feed
      response = HTTParty.get("http://localhost:4567/dashboard/cctray.xml")
      Nokogiri::XML(response.body)
    end
  end
end
