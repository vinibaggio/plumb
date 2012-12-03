require_relative '../../../spec_helper'
require_relative '../../../../lib/plumb/domain/job'
require_relative '../../../../lib/plumb/domain/script'
require_relative '../../../../lib/plumb/domain/jobs'

module Plumb
  module Domain
    describe Jobs do
      describe "fetching a non-existent job" do
        it "sends appropriate not found message to its listener" do
          listener = MiniTest::Mock.new
          repo = Jobs.new(listener, [])
          listener.expect(:job_not_found, nil, ['some-job'])
          repo.fetch('some-job')
          listener.verify
        end
      end

      describe "updating a non-existent job" do
        it "sends appropriate not found message to its listener" do
          listener = MiniTest::Mock.new
          repo = Jobs.new(listener, [])
          listener.expect(:job_not_found, nil, ['some-job'])
          repo.update('some-job', {})
          listener.verify
        end
      end

      describe "storing a job" do
        it "notifies its listener with the new job" do
          listener = MiniTest::Mock.new
          repo = Jobs.new(listener, [])
          job = Job.new(name: 'newly-created')
          listener.expect(:job_created, nil, [job])
          repo << job
          listener.verify
        end
      end

      it "can fetch a job after an update" do
        listener = MiniTest::Mock.new
        def listener.job_created(*); end
        repo = Jobs.new(listener, [])

        repo << Job.new(name: 'Futz')
        script = Domain::Script.new('some-script', 'rake')
        repo.update('Futz', script: script)

        listener.expect(
          :job_found,
          nil,
          [Job.new(name: 'Futz', script: script)]
        )
        repo.fetch('Futz')
        listener.verify
      end

      it "can fetch a job after an update that had no effect" do
        listener = MiniTest::Mock.new
        def listener.job_created(*); end
        repo = Jobs.new(listener, [])

        repo << Job.new(name: 'Futz', foo: 'bar')
        script = Domain::Script.new('some-script', 'rake')
        repo.update('Futz', foo: 'bar')

        listener.expect(
          :job_found,
          nil,
          [Job.new(name: 'Futz', foo: 'bar')]
        )
        repo.fetch('Futz')
        listener.verify
      end
    end
  end
end
