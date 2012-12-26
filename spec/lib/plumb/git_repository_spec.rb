require 'minitest/autorun'
require 'tmpdir'
require_relative '../../../lib/plumb/git_repository'
require_relative '../../support/git_repository'

module Plumb
  class ListenerSpy
    attr_reader :received_working_copy

    def process_working_copy(working_copy)
      @received_working_copy = working_copy
    end

    def received_dir_with_entries(expected_list)
      working_copy_list.must_equal(expected_list)
    end

    private

    def working_copy_list
      Dir.glob(@received_working_copy.path.join('*')).
        map &File.method(:basename)
    end
  end

  describe GitRepository do
    let(:repo_fixture) { SpecSupport::GitRepository.new }
    let(:spy) { ListenerSpy.new }

    after do
      repo_fixture.destroy
    end

    it "clones the repo and passes the working dir to its listener" do
      repo_fixture.create
      repo_fixture.create_good_commit

      Dir.mktmpdir do |projects_dir|
        repo = GitRepository.new(projects_dir)

        repo.fetch(repo_fixture.url, spy)

        paths_in_repo = Dir.glob(repo_fixture.url.join('*'))
        filenames_in_repo = paths_in_repo.map &File.method(:basename)

        spy.received_dir_with_entries filenames_in_repo
      end
    end

    it "raises an exception if the repository cannot be cloned" do
      Dir.mktmpdir do |dir|
        repo = GitRepository.new(dir)
        ->{ repo.fetch('/bad/url') }.must_raise GitRepository::CloneError
      end
    end
  end
end
