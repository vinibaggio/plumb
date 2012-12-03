require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/job'

module Plumb
  module Domain
    describe Job do
      it "can return its attributes" do
        attributes = {name: 'deploy', script: 'rake deploy'}
        Job.new(attributes).attributes.must_equal(attributes)
      end
    end
  end
end

