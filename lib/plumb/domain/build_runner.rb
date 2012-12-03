require_relative 'build_failure'

module Plumb
  module Domain
    class BuildRunner
      attr_writer :listener

      def run_build(build)
        @listener.build_failed(
          BuildFailure.new(build)
        )
      end
    end
  end
end

