require 'minitest/autorun'
require 'tmpdir'
require 'pathname'
require_relative '../../../lib/plumb/filesystem_job_storage'

module Plumb
  describe FileSystemJobStorage do
    it "stores and retrieves jobs, across instances" do
      Dir.mktmpdir do |dir|
        storage1 = FileSystemJobStorage.new('test', Pathname(dir).join('db.json'))
        storage2 = FileSystemJobStorage.new('test', Pathname(dir).join('db.json'))

        storage1 << job = Job.new(foo: 'bar')
        storage1.jobs.must_equal [job]
        storage2.jobs.must_equal [job]
      end
    end

    it "clears all jobs, across instances" do
      Dir.mktmpdir do |dir|
        storage1 = FileSystemJobStorage.new('test', Pathname(dir).join('db.json'))
        storage2 = FileSystemJobStorage.new('test', Pathname(dir).join('db.json'))
        storage1 << job = Job.new(foo: 'bar')

        storage2.jobs.wont_be :empty?
        storage1.clear
        storage1.jobs.must_be :empty?
        storage2.jobs.must_be :empty?
      end
    end
  end
end
