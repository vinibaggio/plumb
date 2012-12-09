require 'json'
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
        if job.repository
          store_repo(name, job.repository.url, job.repository.commits)
        end
      end

      def [](search_name)
        attributes_for(search_name).tap do |attributes|
          return attributes && Domain::Job.new(attributes)
        end
        nil
      end

      def fetch(search_name, &block)
        self[search_name] || block.call
      end

      def delete(name)
        FileUtils.remove_entry_secure job_path(name)
      end

      private

      def attributes_for(search_name) 
        attribute_sets.find {|attributes| attributes[:name] == search_name}
      end

      def attribute_sets
        names.map {|name|
          script = script_from_name(name)
          repository = repo_from_name(name)
          {name: name}.tap do |attributes|
            attributes.merge!(script: script) if script
            attributes.merge!(repository: repository) if repository
          end
        }
      end

      def names
        Dir["#{jobs_path}/*"].map &File.public_method(:basename)
      end

      def repo_config(name)
        raw_file = File.read(job_path(name).join('config.json'))
        puts raw_file
        JSON.parse(raw_file)
      rescue JSON::ParserError => e
        raise JSON::ParserError,
          "#{raw_file} could not be parsed\n#{e.message}"
      end

      def repo_from_name(name) 
        repo, commits = repo_config(name).values_at('repository', 'commits')
        Domain::GitRepository.new(
          repo,
          (commits.map {|sha| Domain::Commit.new(sha)} if commits)
        )
      rescue Errno::ENOENT
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

      def store_repo(name, url, commits)
        File.open(job_path(name).join('config.json'), 'w+') do |file|
          file << JSON.generate(repository: url, commits: commits)
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

