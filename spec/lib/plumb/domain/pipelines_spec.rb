require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/domain/pipelines'

module Plumb
  module Domain
    describe Pipelines do
      describe "fetching a non-existent pipeline" do
        it "returns nil" do
          listener = MiniTest::Mock.new
          repo = Pipelines.new(listener, Set.new)
          listener.expect(
            :pipeline_not_found,
            nil,
            ['some-pipeline']
          )
          repo.fetch('some-pipeline')
          listener.verify
        end
      end

      describe "updating a non-existent pipeline" do
        it "sends appropriate not found messages to its listener" do
          listener = MiniTest::Mock.new
          repo = Pipelines.new(listener, Set.new)
          listener.expect(
            :pipeline_not_found,
            nil,
            ['some-pipeline']
          )
          repo.update('some-pipeline', {})
          listener.verify
        end
      end

      describe "storing a pipeline" do
        it "notifies its listener with the new pipeline" do
          listener = MiniTest::Mock.new
          repo = Pipelines.new(listener, Set.new)
          pipeline = Pipeline.new(name: 'newly-created')
          listener.expect(
            :pipeline_created,
            nil,
            [pipeline]
          )
          repo << pipeline
          listener.verify
        end
      end

      it "can store and update pipelines" do
        listener = MiniTest::Mock.new
        def listener.pipeline_created(*); end
        repo = Pipelines.new(listener, Set.new)

        repo << Pipeline.new(name: 'Futz')
        repo.update('Futz', some: 'attribute')

        listener.expect(
          :pipeline_found,
          nil,
          [Pipeline.new(name: 'Futz', some: 'attribute')]
        )
        repo.fetch('Futz')
        listener.verify
      end
    end
  end
end
