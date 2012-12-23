require 'minitest/autorun'
require 'json'
require_relative '../../../lib/plumb/message'

module Plumb
  describe Message do
    it "allows access to individual properties" do
      Message.new(JSON.generate(name: 'foo'))['name'].must_equal 'foo'
    end

    it "returns its attributes" do
      attributes = {
        'name' => 'apple',
        'color' => 'green',
        'variety' => 'granny smith'
      }
      Message.new(JSON.generate(attributes)).
        attributes.must_equal(attributes)
    end
  end
end
