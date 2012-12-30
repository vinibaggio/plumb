require 'minitest/autorun'
require 'json'
require 'rack/test'
require 'nokogiri'

ENV['RACK_ENV'] = 'test' # must be before server require
require_relative '../../web/server'

describe "web server" do
  include Rack::Test::Methods

  it "has an empty feed when no builds have been stored" do
    delete_all_jobs
    get '/dashboard/cctray.xml'
    feed.css("Projects>Project").must_be_empty
  end

  it "shows a successful build in the feed" do
    delete_all_jobs

    put '/builds/1', Plumb::BuildStatus.new(
      build_id: 1,
      job: Plumb::Job.new(id: 'job1', name: 'AceProject'),
      status: 'success'
    ).to_json

    get '/dashboard/cctray.xml'

    assert project('AceProject'),
      "The stored Job did not appear as a Project in the feed:\n\n#{feed.to_s}"
    project('AceProject')['lastBuildStatus'].must_equal 'Success'
  end

  it "shows a failed build in the feed" do
    delete_all_jobs

    put '/builds/3', Plumb::BuildStatus.new(
      build_id: 1,
      job: Plumb::Job.new(id: 'job3', name: 'My Project'),
      status: 'failure'
    ).to_json

    get '/dashboard/cctray.xml'

    assert project('My Project'),
      "The stored Job did not appear as a Project in the feed:\n\n#{feed.to_s}"
    project('My Project')['lastBuildStatus'].must_equal 'Failure'
  end

  def delete_all_jobs
    delete "/jobs/all"
    assert last_response.ok?, "bad DELETE response"
  end

  def project(name)
    feed.css("Projects>Project[name='#{name}']").first
  end

  def feed
    Nokogiri::XML(last_response.body)
  end

  def app
    Plumb::Server
  end
end
