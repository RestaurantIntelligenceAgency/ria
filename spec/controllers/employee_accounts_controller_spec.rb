require 'spec/spec_helper'

describe EmployeeAccountsController do
  
  describe "POST create" do
    
    let(:user) { Factory(:user) }
    let(:restaurant) { Factory(:managed_restaurant, :manager => user) }
    let(:employee) { Factory(:user) }
    
    before(:each) do
      restaurant.subscription = Factory(:subscription, :payer => restaurant)
      controller.stubs(:current_user).returns(user)
      restaurant.employees << employee
      restaurant.save!
    end
    
    describe "with a premium account and a basic user" do
      
      before(:each) do
        BraintreeConnector.expects(:set_add_ons_for_subscription).with(
            restaurant.subscription, 1).returns(stub(:success? => true))
        post :create, :restaurant_id => restaurant.id, :id => user.id
      end
      
      it "should create the correct user account" do
        restaurant.should have(2).paid_subscriptions
        user.subscription.should be_staff_account
      end
      
      it "redirects back to the employee edit page" do
        flash[:error].should be_nil
        response.should redirect_to(edit_restaurant_employee_path(restaurant, user))
      end
    end
    
    describe "with a braintree failure" do
      
      before(:each) do
        BraintreeConnector.expects(:set_add_ons_for_subscription).with(
            restaurant.subscription, 1).returns(stub(:success? => false))
        post :create, :restaurant_id => restaurant.id, :id => user.id
      end
      
      it "does not create a user account" do
        restaurant.should have(1).paid_subscription
        user.subscription.should be_nil
      end
      
      it "redirects back to the employee page" do
        flash[:error].should_not be_nil
        response.should redirect_to(edit_restaurant_employee_path(restaurant, user))
      end
      
    end
    
    describe "with a security failure" do
      
      before(:each) do
        BraintreeConnector.expects(:set_add_ons_for_subscription).never
        post :create, :restaurant_id => restaurant.id, :id => Factory(:user).id
      end
      
      it "does not create a user account" do
        restaurant.should have(1).paid_subscription
        user.subscription.should be_nil
      end
      
      it "redirects back to the employee page" do
        flash[:error].should_not be_nil
        response.should redirect_to(root_url)
      end
      
    end
    
    describe "if the restaurant doesn't have a premium account" do
      
      before(:each) do
        Subscription.delete_all
        restaurant.update_attributes(:subscription => nil)
        BraintreeConnector.expects(:set_add_ons_for_subscription).never
        post :create, :restaurant_id => restaurant.id, :id => user.id
      end
      
      it "does not create a user account" do
        restaurant.should have(:no).paid_subscriptions
        user.subscription.should be_nil
      end
      
      it "redirects back to the employee page" do
        flash[:error].should_not be_nil
        response.should redirect_to(edit_restaurant_employee_path(restaurant, user))
      end
      
    end
    
    desc "with a premium account an existing add on, and a basic user" do
      
    end
    
  end
  
end