require 'fileutils'
require 'pathname'
require 'git'

class GitRepository
  def initialize(options)
    @email = options[:author]
  end

  def create
    @path = Pathname.new(Dir.mktmpdir)
    @git = Git.init(@path.to_s)
    @git.config('user.email', @email)
  end

  def destroy
    FileUtils.remove_entry_secure(@path)
  end

  def create_bad_commit
    File.open(@path.join('Rakefile'), 'w+') do |file|
      file << 'bad rakefile contents'
    end

    @git.add('.')
    @git.commit('bad commit')
    @git.gcommit('HEAD').sha
  end
end

