require 'pathname'
require 'fileutils'
require_relative '../domain/job'

module Plumb
  module Infrastructure
    class JobFileSystemStorage
      def initialize(dir)
        @path = Pathname.new(dir)
      end

      def []=(name, job)
        make_directory(name)
        store_script(name, job.script)
      end

      def [](search_name)
        each_stored_attributes do |attributes|
          if attributes[:name] == search_name
            return Domain::Job.new(attributes)
          end
        end
      end

      def fetch(search_name, &block)
        self[search_name] || block.call
      end

      def delete(name)
        FileUtils.remove_entry_secure job_path(name)
      end

      private

      def each_stored_attributes
        each_name do |name|
          script = script_from_name(name)
          attributes = {name: name}
          yield script ? attributes.merge(script: script) : attributes
        end
        nil
      end

      def script_from_name(name)
        return nil if first_script_path(name).nil?
        Domain::Script.new(File.basename(first_script_path(name)),
                           File.read(first_script_path(name)))
      end

      def make_directory(name)
        FileUtils.mkdir_p scripts_path(name)
      end

      def store_script(name, script)
        return nil unless script
        File.open(scripts_path(name).join(script.name), 'w+') do |file|
          file << script.source
        end
      end

      def each_name
        Dir["#{jobs_path}/*"].each do |name|
          yield File.basename(name)
        end
      end

      def jobs_path
        @path.join('jobs')
      end

      def job_path(name)
        jobs_path.join(name)
      end

      def scripts_path(job_name)
        job_path(job_name).join('scripts')
      end

      def first_script_path(job_name)
        Dir["#{scripts_path(job_name)}/*"].first
      end
    end
  end
end

