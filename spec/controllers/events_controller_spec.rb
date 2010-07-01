require 'spec_helper'

describe EventsController do
  before(:each) do
    fake_normal_user
    @restaurant = Factory(:restaurant)
    @restaurant.employees << @user
  end

  it "should allow a user to create a new event" do
    event_params = Factory.attributes_for(:event)

    post :create, :event => event_params, :restaurant_id => @restaurant.id
    response.should be_redirect
    assigns[:restaurant].should == @restaurant
    @restaurant.events.count.should == 1
  end
  
  it "should allow a user to update an event" do
    event = Factory(:event, :restaurant => @restaurant)
    Event.stubs(:find).returns(event)
    event.expects(:update_attributes).with("title" => "New title").returns(true)
    put :update, :event => { :title => "New title" }, :id => event.id, :restaurant_id => @restaurant
    response.should be_redirect
  end

end
