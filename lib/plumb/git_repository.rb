require 'pathname'
require_relative 'working_copy'

module Plumb
  class GitRepository
    def initialize(base_dir)
      @base_dir = Pathname(base_dir)
    end

    def fetch(url, listener)
      project_name = File.basename(url)
      working_copy_path = @base_dir.join(project_name)
      `git clone #{url} #{working_copy_path}`
      listener.process_working_copy(
        WorkingCopy.new(working_copy_path)
      )
    end
  end
end

