module Plumb
  module Domain
    class Build < Struct.new(:pipeline, :job, :details)

    end
  end
end
