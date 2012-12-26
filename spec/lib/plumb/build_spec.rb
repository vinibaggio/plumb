require 'minitest/autorun'
require 'tempfile'
require 'tmpdir'
require_relative '../../../lib/plumb/build'
require_relative '../../../lib/plumb/job'

module Plumb
  describe Build do
    let(:unused_reporter) { Object.new.tap {|stub| def stub.build_completed(*); end } }
    let(:unused_repo) { Object.new.tap {|stub| def stub.fetch(*); end } }

    it "requests a copy of the code from the repo" do
      repo = MiniTest::Mock.new
      url = '/some/repo.git'
      build = Build.new(
        Job.new(repository_url: url),
        repo,
        unused_reporter
      )

      repo.expect(:fetch, nil, [url, build])
      build.run
      repo.verify
    end

    describe "when the code is ready" do
      it "runs the job's script from the working copy" do
        job = Job.new(script: './make_stuff_happen')
        side_effect_file = Tempfile.new('side_effect_receiver')
        script = "echo 'script output' > #{side_effect_file.path}"

        Dir.mktmpdir do |working_copy_path|
          working_copy = Dir.new(working_copy_path)
          File.open(working_copy.path + "/make_stuff_happen", 'w') do |file|
            file << script
            file.chmod(500)
          end

          build = Build.new(job, unused_repo, unused_reporter)
          build.process_working_copy(working_copy)

          side_effect_file.read.strip.must_equal "script output"
        end
      end
    end

    describe "when the script has a zero exit code" do
      it "sends a successful build to the reporter" do
        reporter = MiniTest::Mock.new
        job = Job.new(script: 'true')
        Dir.mktmpdir do |working_copy_path|
          working_copy = Dir.new(working_copy_path)

          build = Build.new(job, unused_repo, reporter)

          reporter.expect(
            :build_completed,
            nil,
            [BuildStatus.new(build_id: 1, job: job, status: :success)]
          )
          build.process_working_copy(working_copy)
          reporter.verify
        end
      end
    end

    describe "when the script has a non-zero exit code" do
      it "sends a failed build to the reporter" do
        reporter = MiniTest::Mock.new
        job = Job.new(script: 'false')
        Dir.mktmpdir do |working_copy_path|
          working_copy = Dir.new(working_copy_path)

          build = Build.new(job, unused_repo, reporter)

          reporter.expect(
            :build_completed,
            nil,
            [BuildStatus.new(build_id: 1, job: job, status: :failure)]
          )
          build.process_working_copy(working_copy)
          reporter.verify
        end
      end
    end

    describe "when the code is not available" do
      it "sends a failed build to the reporter"
    end
  end
end
