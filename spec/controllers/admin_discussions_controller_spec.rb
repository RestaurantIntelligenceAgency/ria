require 'spec/spec_helper'

describe AdminDiscussionsController do
  integrate_views
  before do
    fake_normal_user
    @restaurant = Factory(:restaurant, :manager => @user)
    @trend_question = Factory(:trend_question)
    @admin_discussion = AdminDiscussion.create!(:restaurant => @restaurant, :discussionable => @trend_question)
  end

  describe "GET 'show'" do
    before do
      get :show, :id => @admin_discussion.id
    end
    it { response.should be_success }
    it { assigns[:discussionable].should == @trend_question }
  end
end
