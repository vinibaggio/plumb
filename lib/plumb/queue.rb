require_relative 'message'

module Plumb
  class Queue
    attr_accessor :name

    def initialize(name, options = {})
      @name = name
      @path = File.expand_path("../../.../../../queues/#{name}", __FILE__)
    end

    def <<(item)
      File.open(@path, 'a') do |file|
        file.puts item.to_json
      end
    end

    def pop
      lines = IO.readlines(@path)
      line = lines.delete_at(0) or return
      line.strip!
      File.open(@path, 'w') do |file|
        lines.each do |line|
          file.puts line
        end
      end
      Message.new(line)
    rescue Errno::ENOENT
    end

    def clear
      File.unlink(@path)
    rescue Errno::ENOENT
    end
  end
end
