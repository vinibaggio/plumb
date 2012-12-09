require 'tmpdir'
require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/commit'
require_relative '../../../../lib/plumb/domain/script'
require_relative '../../../../lib/plumb/domain/git_repository'
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
        storage1['foo'] = stored_job

        storage2 = JobFileSystemStorage.new(dir)
        found_job = storage2['foo']
        found_job.must_equal stored_job
      end

      it "can store and retrieve jobs without scripts" do
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(name: 'foo')
        storage1['foo'] = stored_job

        storage2 = JobFileSystemStorage.new(dir)
        found_job = storage2['foo']
        found_job.must_equal stored_job
      end

      it "can store and retrieve jobs with repositories" do
        commit_1 = Domain::Commit.new('asdf')
        commit_2 = Domain::Commit.new('fdsa')
        repo = Domain::GitRepository.new(
          'git@github.com:camelpunch/some-repo.git',
          [commit_1, commit_2]
        )
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(
          name: 'foo',
          repository: repo
        )
        storage1['foo'] = stored_job

        storage2 = JobFileSystemStorage.new(dir)
        found_job = storage2['foo']
        found_job.repository.must_equal repo
      end

      it "can store and retrieve jobs with repositories without commits" do
        repo = Domain::GitRepository.new(
          'git@github.com:camelpunch/some-repo.git'
        )
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(
          name: 'foo',
          repository: repo
        )
        storage1['foo'] = stored_job

        storage2 = JobFileSystemStorage.new(dir)
        found_job = storage2['foo']
        found_job.repository.must_equal repo
      end

      describe "finding a job not stored" do
        it "returns nil" do
          storage = JobFileSystemStorage.new(dir)
          storage['foo'].must_be_nil
        end

        it "returns the default value" do
          storage = JobFileSystemStorage.new(dir)
          storage.fetch('foo') { 'bar' }.must_equal('bar')
        end
      end

      it "can delete jobs" do
        storage1 = JobFileSystemStorage.new(dir)
        stored_job = Domain::Job.new(name: 'foo')
        storage1['foo'] = stored_job

        storage2 = JobFileSystemStorage.new(dir)
        storage2.delete('foo')

        storage1['foo'].must_be_nil
      end
    end
  end
end
