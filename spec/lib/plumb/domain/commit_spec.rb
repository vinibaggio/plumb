require 'minitest/autorun'
require_relative '../../../../lib/plumb/domain/commit'

module Plumb
  module Domain
    describe Commit do
      it "holds a sha" do
        Commit.new('asdf').sha.must_equal 'asdf'
      end

      it "requires a sha" do
        ->{Commit.new(nil)}.must_raise Commit::InvalidSHA
        ->{Commit.new('  ')}.must_raise Commit::InvalidSHA
      end

      it "uses just the SHA when serializing to JSON" do
        Commit.new("ASDF").to_json(:arbitrary_options).must_equal '"ASDF"'
      end

      it "is equivalent to a commit with same sha" do
        Commit.new('poo').must_equal Commit.new('poo')
        Commit.new('foo').wont_equal Commit.new('poo')
      end
    end
  end
end
