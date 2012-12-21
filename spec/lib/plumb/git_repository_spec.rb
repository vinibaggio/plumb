require 'minitest/autorun'
require_relative '../../../lib/plumb/git_repository'
require_relative '../../../lib/plumb/commit'

module Plumb
  describe GitRepository do
    it "contains a URL and commits" do
      commit_1 = Plumb::Commit.new('somesha')
      commit_2 = Plumb::Commit.new('someothersha')
      repo = GitRepository.new('/somerepo', [commit_1, commit_2])
      repo.commits.must_equal [commit_1, commit_2]
    end
  end
end
