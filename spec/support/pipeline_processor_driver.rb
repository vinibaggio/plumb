require 'json'

module SpecSupport
  class PipelineProcessorDriver
    attr_reader :cmd_path

    def initialize
      @cmd_path = File.expand_path('../../../bin/plumb-pipeline-processor', __FILE__)
    end

    def run_pipeline(pipeline)
      cmd = "echo '#{JSON.generate(pipeline)}' | #{cmd_path}"
      system cmd or raise "command failed"
    end
  end
end
