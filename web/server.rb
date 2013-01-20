#!/usr/bin/env ruby
require 'sinatra/base'
require_relative '../lib/plumb/build_status'
require_relative '../lib/plumb/job'
require_relative '../lib/plumb/filesystem_job_storage'

module Plumb
  class Server < Sinatra::Base
    FEED_PATH = File.expand_path('../cc.xml', __FILE__)
    DATABASE_NAME = "db-#{ENV['RACK_ENV'] || 'production'}.json"
    STORAGE = Plumb::FileSystemJobStorage.new(
      ENV['RACK_ENV'],
      File.expand_path("../#{DATABASE_NAME}", __FILE__)
    )

    get '/dashboard/cctray.xml' do
      @jobs = STORAGE.jobs
      erb :cctray
    end

    put "/builds/:id" do
      build_status = Plumb::BuildStatus.new(JSON.parse(request.body.read))
      STORAGE << build_status.job.merge(
        last_build_status: build_status.status
      )
      '{}'
    end

    delete "/jobs/:id" do
      STORAGE.clear
      '{}'
    end

    private

    run! if app_file == $0
  end
end
