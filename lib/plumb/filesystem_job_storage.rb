require_relative 'job'

module Plumb
  class FileSystemJobStorage
    def initialize(environment, storage_path)
      @environment = environment
      @storage_path = storage_path
    end

    def to_a
      JSON.parse(data).map {|attributes| Plumb::Job.new(attributes)}
    end

    def <<(job)
      new_jobs = to_a
      new_jobs << job
      File.open(@storage_path, 'w') do |file|
        file << new_jobs.to_json
      end
    end

    def clear
      File.unlink @storage_path
    rescue Errno::ENOENT
    end

    private

    def data
      unless File.exists?(@storage_path)
        File.open(@storage_path, 'w') do |file|
          file << '[]'
        end
      end
      File.read(@storage_path)
    end
  end
end

