require 'minitest/autorun'
require 'tmpdir'
require 'pathname'
require_relative '../../../lib/plumb/filesystem_job_storage'

module Plumb
  describe FileSystemJobStorage do
    it "stores and retrieves jobs, across instances" do
      with_nonexistent_file_path do |path|
        storage1 = FileSystemJobStorage.new('test', path)
        storage2 = FileSystemJobStorage.new('test', path)

        storage1 << job = Job.new(foo: 'bar')
        storage1.jobs.must_equal [job]
        storage2.jobs.must_equal [job]
      end
    end

    it "clears all jobs, across instances" do
      with_nonexistent_file_path do |path|
        storage1 = FileSystemJobStorage.new('test', path)
        storage2 = FileSystemJobStorage.new('test', path)
        storage1 << job = Job.new(foo: 'bar')

        storage2.jobs.wont_be :empty?
        storage1.clear
        storage1.jobs.must_be :empty?
        storage2.jobs.must_be :empty?
      end
    end

    def with_nonexistent_file_path
      Dir.mktmpdir do |dir|
        yield Pathname(dir).join('db.json')
      end
    end
  end
end
