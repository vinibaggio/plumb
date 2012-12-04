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

      def []=(name, pipeline)
        raise ArgumentError, "storage key is nil!" if name.nil?
        make_directory(pipeline)
        store_order(pipeline)
      end

      def [](search_name)
        each_name do |name|
          if name == search_name
            return Domain::Pipeline.new(
              name: name,
              order: get_order(name)
            )
          end
        end
      end

      def fetch(search_name, &block)
        self[search_name] || block.call
      end

      def delete(name)
        FileUtils.remove_entry_secure pipeline_path(name)
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

      def get_order(name)
        if File.exists?(order_file_path(name)) then
          JSON.parse(File.read(order_file_path(name)))
        else
          []
        end
      end

      def order_file_path(pipeline_name)
        pipeline_path(pipeline_name).join('order.json')
      end

      def each_name
        Dir["#{pipelines_path}/*"].each do |name|
          yield File.basename(name)
        end
        nil
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

