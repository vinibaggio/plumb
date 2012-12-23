require 'httparty'

module Plumb
  class WebReporter
    def initialize(url)
      @url = url
    end

    def build_completed(status)
      HTTParty.put(@url + "/#{status.build_id}", body: status.to_json)
    end
  end
end
