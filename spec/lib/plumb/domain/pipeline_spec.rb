require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/pipeline'

module Plumb
  module Domain
    describe Pipeline do
      it "can return its attributes" do
        attributes = {some: 'attributes', for: 'comparison'}
        Pipeline.new(attributes).attributes.must_equal(attributes)
      end

      it "is equivalent to another pipeline with the same name" do
        Pipeline.new(name: 'foo').must_equal(
          Pipeline.new(name: 'foo', order: [])
        )
      end
    end
  end
end

