require 'active_support/inflector'

module SpecSupport
  def self.const_missing(name)
    require File.expand_path("../support/#{name.to_s.underscore}", __FILE__)
    "SpecSupport::#{name}".constantize
  end
end

