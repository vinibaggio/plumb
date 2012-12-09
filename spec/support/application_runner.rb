require 'fileutils'
require 'json'
require 'tmpdir'

class ApplicationRunner
  attr_reader :working_path, :plumb_path

  def initialize
    @plumb_path = File.expand_path('../../../bin/plumb', __FILE__)
  end

  def start
    @working_path = Pathname.new(Dir.mktmpdir)
  end

  def stop
    FileUtils.remove_entry_secure(working_path)
  end

  def add_pipeline(name)
    @pipelines ||= {}
    @pipelines[name] = {}
    #plumb "pipeline create #{name}"
  end

  def add_pipeline_notification_emails(name, email)
    @pipelines[name][:notification_email] = email
    #plumb "pipeline #{name} email_notification create #{email}"
  end

  def add_job(name, options)
    pipeline = options.fetch :pipeline
    repo = options.fetch :repository_url
    script = options.fetch :script

    @pipelines[pipeline][:order] ||= []
    @pipelines[pipeline][:order] << [{
      name: name,
      repository_url: repo,
      script: script
    }]
    #plumb "job create #{name} #{repo}"
    #plumb "job #{name} script create script_1 '#{script}'"
    #plumb "pipeline #{pipeline} job append #{name}"
  end

  def run_pipeline(name)
    cmd = "cd #{working_path}; echo '#{JSON.generate(@pipelines[name])}' | #{plumb_path} pipeline run"
    puts cmd
    system cmd or raise "command failed"
  end
end
