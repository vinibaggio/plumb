#!/usr/bin/env ruby
require 'sinatra'

get '/dashboard/cctray.xml' do
  send_file File.expand_path('../cc.xml', __FILE__)
end

put "/builds/:id" do

end
