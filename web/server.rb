#!/usr/bin/env ruby
require 'sinatra/base'
require_relative '../lib/plumb/build_status'
require_relative '../lib/plumb/job'

module Plumb
  class Server < Sinatra::Base
    FEED_PATH = File.expand_path('../cc.xml', __FILE__)

    get '/dashboard/cctray.xml' do
      @jobs = JSON.parse(File.read(storage_path)).map {|attributes|
        Plumb::Job.new(attributes)
      }
      erb :cctray
    end

    put "/builds/:id" do
      build_status = Plumb::BuildStatus.new(JSON.parse(request.body.read))
      jobs = JSON.parse(File.read(storage_path))
      jobs << build_status.job.merge(
        last_build_status: build_status.status
      )
      File.open(storage_path, 'w') do |file|
        file << jobs.to_json
      end
      '{}'
    end

    delete "/jobs/:id" do
      File.unlink storage_path
      '{}'
    end

    private

    def storage_path
      File.expand_path('../db.json', __FILE__).tap do |path|
        unless File.exists?(path)
          File.open(path, 'w') do |file|
            file << '[]'
          end
        end
      end
    end

    run! if app_file == $0
  end
end
