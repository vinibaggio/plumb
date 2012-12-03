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
        ->{storage << nil}.must_raise ArgumentError
      end

      it "can store and retrieve" do
        storage1 = PipelineFileSystemStorage.new(dir)
        stored_pipeline = Domain::Pipeline.new(
          name: 'foo',
          order: [
            ['lovely-job']
          ]
        )
        storage1 << stored_pipeline

        storage2 = PipelineFileSystemStorage.new(dir)
        found_pipeline = storage2.find {|pipeline| pipeline.name == 'foo'}
        found_pipeline.must_equal stored_pipeline
      end

      describe "finding a pipeline not stored" do
        it "returns nil" do
          storage = PipelineFileSystemStorage.new(dir)
          storage.find {|pipeline| pipeline.name == 'foo'}.must_be_nil
        end

        it "calls the callback" do
          callable = MiniTest::Mock.new
          storage = PipelineFileSystemStorage.new(dir)
          callable.expect(:call, 'foo', [])
          storage.find(callable) {|pipeline| pipeline.name == 'foo'}.
            must_equal('foo')
          callable.verify
        end
      end

      it "can delete pipelines" do
        storage1 = PipelineFileSystemStorage.new(dir)
        stored_pipeline = Domain::Pipeline.new(name: 'foo')
        storage1 << stored_pipeline

        storage2 = PipelineFileSystemStorage.new(dir)
        storage2.delete(stored_pipeline)

        storage1.find {|pipeline| pipeline.name == 'foo'}.must_be_nil
      end
    end
  end
end
