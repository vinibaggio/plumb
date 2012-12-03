require 'pathname'
require 'fileutils'
require 'json'
require_relative '../domain/pipeline'

module Plumb
  module Infrastructure
    class PipelineFileSystemStorage
      def initialize(dir)
        @path = Pathname.new(dir)
      end

      def <<(pipeline)
        raise ArgumentError, "pipeline name is nil!" if pipeline.nil?
        make_directory(pipeline)
        store_order(pipeline)
      end

      def find(ifnone = nil, &block)
        each_name do |name|
          pipeline = Domain::Pipeline.new(
            name: name,
            order: JSON.parse(File.read(order_file_path(name)))
          )
          return pipeline if yield pipeline
        end
        ifnone.call if ifnone
      end

      def delete(pipeline)
        FileUtils.remove_entry_secure pipeline_path(pipeline.name)
      end

      private

      def make_directory(pipeline)
        FileUtils.mkdir_p pipeline_path(pipeline.name)
      end

      def store_order(pipeline)
        return nil unless pipeline.order
        File.open(order_file_path(pipeline.name), 'w+') do |file|
          file << JSON.generate(pipeline.order)
        end
      end

      def order_file_path(pipeline_name)
        pipeline_path(pipeline_name).join('order.json')
      end

      def each_name
        Dir["#{pipelines_path}/*"].each do |name|
          yield File.basename(name)
        end
      end

      def pipelines_path
        @path.join('pipelines')
      end

      def pipeline_path(pipeline_name)
        pipelines_path.join(pipeline_name)
      end
    end
  end
end

