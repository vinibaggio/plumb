require 'rack/test'
require 'nokogiri'
require_relative '../../web/server'

class WebApplicationDriver
  include Rack::Test::Methods

  def start
    @app = Sinatra::Application
  end

  def stop
  end

  def shows_green_build_xml_for(project_name)
    project(project_name)['activity'].must_equal 'Sleeping'
    project(project_name)['lastBuildStatus'].must_equal 'Success'
  end

  def shows_red_build_xml_for(project_name)
    project(project_name)['activity'].must_equal 'Sleeping'
    project(project_name)['lastBuildStatus'].must_equal 'Failure'
  end

  private

  def feed
    get '/dashboard/cctray.xml'
    Nokogiri::XML(last_response.body)
  end

  def project(name)
    feed.css("Projects>Project[name='#{name}']").first
  end

  def app
    @app
  end
end


