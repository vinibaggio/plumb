require 'json'

module Plumb
  class BuildStatus < Struct.new(:build_id, :status)
    def failure?
      status == :failure
    end

    def success?
      status == :success
    end

    def to_json
      JSON.generate(
        build_id: build_id,
        status: status
      )
    end
  end
end

