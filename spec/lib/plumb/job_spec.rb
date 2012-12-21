require 'minitest/autorun'
require_relative '../../../lib/plumb/job'

module Plumb
  describe Job do
    it "has a JSON representation" do
      Job.new(
        name: 'run tests',
        script: 'rake',
        repository_url: '/some/place'
      ).to_json.must_equal('{"name":"run tests","script":"rake","repository_url":"/some/place"}')
    end

    it "is equivalent to a job with same attributes" do
      Job.new(name: 'foo').must_equal(Job.new(name: 'foo'))
    end

    it "is not equivalent to a job with different attributes" do
      Job.new(name: 'foo').wont_equal(Job.new(name: 'bar'))
    end
  end
end

