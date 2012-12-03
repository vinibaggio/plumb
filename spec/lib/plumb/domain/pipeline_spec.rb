require_relative '../../../spec_helper'
require_relative '../../../../lib/plumb/domain/pipeline'

module Plumb
  module Domain
    describe Pipeline do
      it "can return its attributes" do
        attributes = {some: 'attributes', for: 'comparison'}
        Pipeline.new(attributes).attributes.must_equal(attributes)
      end
    end
  end
end


