require File.dirname(__FILE__) + '/../spec_helper'

describe DateRange do
  it "should be valid" do
    DateRange.new.should be_valid
  end
end
