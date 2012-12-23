require 'minitest/autorun'
require_relative '../../../lib/plumb/build_status'

module Plumb
  describe BuildStatus do
    it "is equivalent to a build with same attributes" do
      BuildStatus.new(1, :failure).must_equal(BuildStatus.new(1, :failure))
    end

    it "is not equivalent to a build with different attributes" do
      BuildStatus.new(1, :failure).wont_equal(BuildStatus.new(1, :success))
    end

    it "has a failure status" do
      BuildStatus.new(1, :failure).must_be :failure?
      BuildStatus.new(1, :failure).wont_be :success?
    end

    it "has a success status" do
      BuildStatus.new(1, :success).must_be :success?
      BuildStatus.new(1, :success).wont_be :failure?
    end

    it "has a JSON representation of its attributes" do
      BuildStatus.new(14, :success).to_json.
        must_equal '{"build_id":14,"status":"success"}'
    end
  end
end
