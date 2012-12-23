module Plumb
  class Message < String
    def to_json
      self
    end

    def [](key)
      JSON.parse(self)[key]
    end

    def attributes
      JSON.parse(self)
    end
  end
end
