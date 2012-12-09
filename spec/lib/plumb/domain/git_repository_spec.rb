require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/git_repository'
require_relative '../../../../lib/plumb/domain/commit'

module Plumb
  module Domain
    describe GitRepository do
      it "contains a URL and commits" do
        commit_1 = Plumb::Domain::Commit.new
        commit_2 = Plumb::Domain::Commit.new
        repo = GitRepository.new('/somerepo', [commit_1, commit_2])
        repo.commits.must_equal [commit_1, commit_2]
      end
    end
  end
end
