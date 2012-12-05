require 'minitest/autorun'
require 'tmpdir'
require_relative '../../../../lib/plumb/domain/pipeline'
require_relative '../../../../lib/plumb/infrastructure/pipeline_filesystem_storage'

module Plumb
  module Infrastructure
    describe PipelineFileSystemStorage do
      let(:dir) { Dir.mktmpdir }

      after do
        FileUtils.remove_entry_secure(dir)
      end

      it "raises if attempt is made to make pipeline with nil name" do
        storage = PipelineFileSystemStorage.new(dir)
        ->{storage[nil] = Domain::Pipeline.new(name: nil)}.must_raise ArgumentError
      end

      it "can store and retrieve" do
        storage1 = PipelineFileSystemStorage.new(dir)
        stored_pipeline = Domain::Pipeline.new(
          name: 'foo',
          order: [ ['lovely-job'] ]
        )
        storage1['foo'] = stored_pipeline

        storage2 = PipelineFileSystemStorage.new(dir)
        found_pipeline = storage2['foo']
        found_pipeline.must_equal stored_pipeline
      end

      it "can overwrite attributes after initial storage" do
        storage1 = PipelineFileSystemStorage.new(dir)
        stored_pipeline = Domain::Pipeline.new(
          name: 'foo',
          order: [ ['lovely-job'] ]
        )
        storage1['foo'] = stored_pipeline

        storage2 = PipelineFileSystemStorage.new(dir)
        stored_pipeline = Domain::Pipeline.new(
          name: 'foo',
          order: [ ['lovely-job'] ],
          notification_email: 'some@address.co'
        )
        storage2['foo'] = stored_pipeline
        found_pipeline = storage2['foo']
        found_pipeline.notification_email.must_equal 'some@address.co'
      end

      describe "finding a pipeline not stored" do
        it "returns nil" do
          storage = PipelineFileSystemStorage.new(dir)
          storage['foo'].must_be_nil
        end

        it "returns the default value" do
          storage = PipelineFileSystemStorage.new(dir)
          storage.fetch('foo') { 'bar' }.must_equal('bar')
        end
      end

      describe "finding a pipeline without an order of jobs" do
        it "returns the pipeline" do
          storage1 = PipelineFileSystemStorage.new(dir)
          stored_pipeline = Domain::Pipeline.new(name: 'foo')
          storage1['foo'] = stored_pipeline

          storage2 = PipelineFileSystemStorage.new(dir)
          found_pipeline = storage2['foo']
          found_pipeline.must_equal stored_pipeline
        end
      end

      it "can delete pipelines" do
        storage1 = PipelineFileSystemStorage.new(dir)
        stored_pipeline = Domain::Pipeline.new(name: 'foo')
        storage1['foo'] = stored_pipeline

        storage2 = PipelineFileSystemStorage.new(dir)
        storage2.delete('foo')

        storage1['foo'].must_be_nil
      end
    end
  end
end
