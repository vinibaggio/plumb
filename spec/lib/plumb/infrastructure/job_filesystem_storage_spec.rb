require 'tmpdir'
require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/script'
require_relative '../../../../lib/plumb/infrastructure/job_filesystem_storage'

module Plumb
  module Infrastructure
    describe JobFileSystemStorage do
      let(:dir) { Dir.mktmpdir }

      after do
        FileUtils.remove_entry_secure(dir)
      end

      it "can store and retrieve jobs with scripts" do
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(
          name: 'foo',
          script: Domain::Script.new('run_rake', 'rake')
        )
        storage1 << stored_job

        storage2 = JobFileSystemStorage.new(dir)
        found_job = storage2.find {|job| job.name == 'foo'}
        found_job.must_equal stored_job
      end

      it "can store and retrieve jobs without scripts" do
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(name: 'foo')
        storage1 << stored_job

        storage2 = JobFileSystemStorage.new(dir)
        found_job = storage2.find {|job| job.name == 'foo'}
        found_job.must_equal stored_job
      end

      describe "finding a job not stored" do
        it "returns nil" do
          storage = JobFileSystemStorage.new(dir)
          storage.find {|job| job.name == 'foo'}.must_be_nil
        end

        it "calls the callback" do
          callable = MiniTest::Mock.new
          storage = JobFileSystemStorage.new(dir)
          callable.expect(:call, 'foo', [])
          storage.find(callable) {|job| job.name == 'foo'}.
            must_equal('foo')
          callable.verify
        end
      end

      it "can delete jobs" do
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(name: 'foo')
        storage1 << stored_job

        storage2 = JobFileSystemStorage.new(dir)
        storage2.delete(stored_job)

        storage1.find {|job| job.name == 'foo'}.must_be_nil
      end
    end
  end
end
