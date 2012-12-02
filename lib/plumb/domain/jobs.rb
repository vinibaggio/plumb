require 'set'

module Plumb
  module Domain
    class Jobs
      def initialize(listener)
        @listener = listener
        @jobs = Set.new
      end

      def <<(job)
        @jobs << job
        @listener.job_created(job)
      end

      def fetch(name)
        find_job(name) do |job|
          @listener.job_found(job)
        end
      end

      def update(name, attributes)
        find_job(name) do |job|
          self << Job.new(job.attributes.merge(attributes))
          @jobs.delete(job)
        end
      end

      private

      def find_job(name)
        job = @jobs.find ->{ @listener.job_not_found(name) } {|job|
          job.name == name
        }

        yield job if job
      end
    end
  end
end
