require 'spec_helper'

describe Comparator do

  context ".diff" do

    it "should respect optional arguments when doing a diff on matchers" do

      HashDealer.define(:comparator_with_options) do
        required_val("val")
        optional_val("opt", optional: true)
      end

      matcher = HashDealer.roll(:comparator_with_options).matcher

      Comparator.diff(matcher, {:required_val => "x", :optional_val => "y"}).should eql({})

      Comparator.diff(matcher, {:required_val => "x"}).should eql({})
      Comparator.diff(matcher, {:optional_val => "x"}).should_not eql({})


    end

  end

end