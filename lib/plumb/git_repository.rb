require 'pathname'
require_relative 'working_copy'

module Plumb
  class GitRepository
    CloneError = Class.new(StandardError)

    def initialize(base_dir)
      @base_dir = Pathname(base_dir)
    end

    def fetch(url, listener = NullListener.new)
      project_name = File.basename(url)
      working_copy_path = @base_dir.join(project_name)
      puts "Attempting to clone #{url} into #{working_copy_path}"

      if system "git clone #{url} #{working_copy_path}"
        listener.process_working_copy(
          WorkingCopy.new(working_copy_path)
        )
      else
        raise CloneError
      end
    end

    class NullListener
      def process_working_copy(*)
      end
    end
  end
end

