require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  integrate_views

  before(:each) do
    @parent = Factory(:media_request_conversation, :id => 8)
    MediaRequestConversation.stubs(:find).returns(@parent)
  end

  describe "POST create" do
    it "should redirect to parent" do
      Comment.any_instance.stubs(:valid?).returns(true)
      post :create, :media_request_conversation_id => 8, :comment => {}
      response.should redirect_to( media_request_conversation_path(assigns[:parent]) )
    end    
  end
end
