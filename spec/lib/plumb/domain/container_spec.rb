require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/container'

module Plumb
  module Domain
    describe Container do
      describe "fetching a non-existent entity" do
        it "returns nil" do
          listener = MiniTest::Mock.new
          repo = Container.new(Pipeline, listener, {})
          listener.expect(
            :pipeline_not_found,
            nil,
            ['some-pipeline']
          )
          repo.fetch('some-pipeline')
          listener.verify
        end
      end

      describe "updating a non-existent job" do
        it "sends appropriate not found messages to its listener" do
          listener = MiniTest::Mock.new
          repo = Container.new(Job, listener, {})
          listener.expect(
            :job_not_found,
            nil,
            ['some-job']
          )
          repo.update('some-job', {})
          listener.verify
        end
      end

      describe "storing" do
        it "notifies its listener with the new object" do
          Fish = Class.new(OpenStruct)
          listener = MiniTest::Mock.new
          repo = Container.new(Fish, listener, {})
          object = OpenStruct.new(name: 'something')
          listener.expect(:fish_created, nil, [object])
          repo << object
          listener.verify
        end
      end

      it "can store and update objects" do
        listener = MiniTest::Mock.new
        def listener.job_created(*); end
        repo = Container.new(Job, listener, {})

        repo << Job.new(name: 'Abnaki')
        repo.update('Abnaki', some: 'attribute')

        listener.expect(
          :job_found,
          nil,
          [Job.new(name: 'Abnaki', some: 'attribute')]
        )
        repo.fetch('Abnaki')
        listener.verify
      end
    end
  end
end
