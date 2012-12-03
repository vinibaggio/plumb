require 'pathname'
require 'fileutils'
require_relative '../domain/job'

module Plumb
  module Infrastructure
    class JobFileSystemStorage
      def initialize(dir)
        @path = Pathname.new(dir)
      end

      def <<(job)
        make_directory(job)
        store_script(job)
      end

      def find(ifnone = nil, &block)
        each_stored_attributes do |attributes|
          job = Domain::Job.new(attributes)
          return job if yield job
        end
        ifnone.call if ifnone
      end

      def delete(job)
        FileUtils.remove_entry_secure job_path(job.name)
      end

      private

      def each_stored_attributes
        each_name do |name|
          script = script_from_name(name)
          attributes = {name: name}
          yield script ? attributes.merge(script: script) : attributes
        end
      end

      def script_from_name(name)
        return nil if first_script_path(name).nil?
        Domain::Script.new(File.basename(first_script_path(name)),
                           File.read(first_script_path(name)))
      end

      def make_directory(job)
        FileUtils.mkdir_p scripts_path(job.name)
      end

      def store_script(job)
        return nil unless job.script
        File.open(scripts_path(job.name).join(job.script.name), 'w+') do |file|
          file << job.script.source
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

