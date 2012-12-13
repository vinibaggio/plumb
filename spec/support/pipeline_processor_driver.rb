require 'json'

class PipelineProcessorDriver
  attr_reader :working_path, :cmd_path

  def initialize
    @cmd_path = File.expand_path('../../../bin/plumb-pipeline-processor', __FILE__)
  end

  def add_pipeline(name)
    @pipelines ||= {}
    @pipelines[name] = {}
  end

  def add_pipeline_notification_emails(name, email)
    @pipelines[name][:notification_email] = email
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
  end

  def run_pipeline(name)
    cmd = "echo '#{JSON.generate(@pipelines[name])}' | #{cmd_path}"
    system cmd or raise "command failed"
  end
end
