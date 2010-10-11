require 'spec_helper'

describe ProfileAnswer do
  before(:each) do
    @valid_attributes = Factory.attributes_for(:profile_answer, 
                                               :profile_question => Factory(:profile_question), 
                                               :user => Factory(:user))
  end

  it "should create a new instance given valid attributes" do
    ProfileAnswer.create!(@valid_attributes)
  end
end
