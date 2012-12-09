module Plumb
  module Domain
    class GitRepository < Struct.new(:url, :commits)
    end
  end
end


