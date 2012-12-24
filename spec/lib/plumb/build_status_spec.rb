require 'minitest/autorun'
require_relative '../../../lib/plumb/build_status'
require_relative '../../../lib/plumb/job'

module Plumb
  describe BuildStatus do
    it "is equivalent to a build status with same attributes" do
      attributes = {
        build_id: 1,
        job: Job.new(name: 'foo'),
        status: :failure
      }
      BuildStatus.new(attributes).
        must_equal(BuildStatus.new(attributes))
    end

    it "is not equivalent to a build status with different attributes" do
      BuildStatus.new(build_id: 1, status: :failure).
        wont_equal(BuildStatus.new(build_id: 1, status: :success))
    end

    it "has a failure status" do
      BuildStatus.new(status: :failure).must_be :failure?
      BuildStatus.new(status: :failure).wont_be :success?
    end

    it "has a success status" do
      BuildStatus.new(status: :success).must_be :success?
      BuildStatus.new(status: :success).wont_be :failure?
    end

    it "has a JSON representation of its attributes" do
      BuildStatus.new(build_id: 14,
                      job: Job.new(name: 'foo'),
                      status: :success).to_json.
        must_equal '{"build_id":14,"job":{"name":"foo"},"status":"success"}'
    end
  end
end
