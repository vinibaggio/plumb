module Plumb
  class Server
    def call(env)
      path = env['PATH_INFO']
      [201, {"Content-Type" => "application/json"}, "{}"]
    end
  end
end
