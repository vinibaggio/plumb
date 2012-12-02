require_relative '../../../spec_helper'
require_relative '../../../../lib/plumb/domain/job'

module Plumb
  module Domain
    describe Job do
      it "can return its attributes" do
        job_attributes = {name: 'deploy', script: 'rake deploy'}
        Job.new(job_attributes).attributes.must_equal(job_attributes)
      end
    end
  end
end

