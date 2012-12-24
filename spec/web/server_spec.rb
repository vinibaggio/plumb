require 'minitest/autorun'
require 'json'
require 'rack/test'
require 'nokogiri'
require_relative '../../web/server'
require_relative '../../lib/plumb/build_status'
require_relative '../../lib/plumb/job'

describe "web server" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "PUT build" do
    it "updates the build's status in the feed" do
      put '/builds/1', Plumb::BuildStatus.new(
        build_id: 1,
        job: Plumb::Job.new(name: 'AceProject'),
        status: 'success'
      ).to_json

      get '/dashboard/cctray.xml'

      assert project('AceProject'), "no AceProject in feed!"
      project('AceProject').fetch('lastBuildStatus').must_equal 'Success'
    end
  end

  def project(name)
    feed.css("Projects>Project[name='#{name}']").first
  end

  def feed
    Nokogiri::XML(last_response.body)
  end
end
