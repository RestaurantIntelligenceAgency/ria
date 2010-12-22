require 'spec_helper'

describe QuestionsController do

  before(:each) do
    @user = Factory(:user)
    controller.stubs(:current_user).returns(@user)
  end

  describe "topics" do

    it "should show you your topics" do
      role = Factory(:restaurant_role)
      @user.stubs(:primary_employment).returns(Factory(:employment, :restaurant_role => role, :employee => @user))
      6.times do
        question_role = Factory(:question_role, :responder => role)
        Factory(:profile_question, :question_roles => [question_role])
      end

      get :topics, :user_id => @user.id
      assigns[:topics].size.should == 6
    end

    it "should show you someone else's topics" do
      profile_user = Factory(:user)
      role = Factory(:restaurant_role)
      profile_user.stubs(:primary_employment).returns(Factory(:employment, :restaurant_role => role, :employee => profile_user))
      4.times do
        question_role = Factory(:question_role, :responder => role)
        question = Factory(:profile_question, :question_roles => [question_role])
        Factory(:profile_answer, :profile_question => question, :responder => profile_user)
      end

      get :topics, :user_id => profile_user.id
      assigns[:topics].size.should == 4
    end

  end

end
