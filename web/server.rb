#!/usr/bin/env ruby
require 'sinatra/base'
require_relative '../lib/plumb/build_status'
require_relative '../lib/plumb/job'

module Plumb
  class Server < Sinatra::Base
    FEED_PATH = File.expand_path('../cc.xml', __FILE__)

    def storage_path
      File.expand_path('../db.json', __FILE__).tap do |path|
        unless File.exists?(path)
          File.open(path, 'w') do |file|
            file << '[]'
          end
        end
      end
    end

    get '/dashboard/cctray.xml' do
      @jobs = JSON.parse(File.read(storage_path)).
        map &Plumb::Job.public_method(:new)
      erb :cctray
    end

    get '/jobs' do
      File.read(storage_path)
    end

    put "/builds/:id" do
      build = Plumb::BuildStatus.new(JSON.parse(request.body.read))
      existing_jobs = JSON.parse(File.read(storage_path))
      existing_jobs << build.job.merge(last_build_status: build.status)
      File.open(storage_path, 'w') do |file|
        file << existing_jobs.to_json
      end
      '{}'
    end

    delete "/jobs/:id" do
      File.unlink storage_path
      '{}'
    end

    run! if app_file == $0
  end
end
