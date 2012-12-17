require 'fileutils'
require 'pathname'
require 'tmpdir'

class GitRepository
  def create
    @path = Pathname.new(Dir.mktmpdir)
    exec "git init"
  end

  def destroy
    FileUtils.remove_entry_secure(@path) if @path
  end

  def create_good_commit
    exec "echo 'task(:default) {}' > Rakefile"
    exec "git add ."
    exec "git commit -m'Good Commit'"
    exec "git rev-parse HEAD"
  end

  def create_bad_commit
    exec "echo 'bad rakefile contents' > Rakefile"
    exec "git add ."
    exec "git commit -m'Bad Commit'"
    exec "git rev-parse HEAD"
  end

  def url
    @path
  end

  private 

  def exec(cmd)
    `cd #{@path}; #{cmd}`.strip
  end
end

