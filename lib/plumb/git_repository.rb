require 'pathname'
require_relative 'working_copy'

module Plumb
  class GitRepository
    def initialize(base_dir)
      @base_dir = Pathname(base_dir)
    end

    def fetch(url, listener = NullListener)
      project_name = File.basename(url)
      working_copy_path = @base_dir.join(project_name)

      remove_existing(working_copy_path)

      if clone(url, working_copy_path)
        listener.process_working_copy WorkingCopy.new(working_copy_path)
      else
        listener.handle_clone_failure
      end
    end

    class NullListener
      class << self
        def process_working_copy(*); end
        def handle_clone_failure(*); end
      end
    end

    private

    def remove_existing(path)
      FileUtils.remove_entry_secure(path) if File.exists?(path)
    end

    def clone(source, destination)
      system "git clone #{source} #{destination} &> /dev/null"
    end
  end
end

