require 'spec/spec_helper'

describe Admin::ContentRequestsController do
  integrate_views
  before(:each) do
    fake_admin_user
    Factory(:content_request)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => ContentRequest.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ContentRequest.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    ContentRequest.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(admin_content_request_path(assigns[:content_request]))
  end

  it "edit action should render edit template" do
    get :edit, :id => ContentRequest.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    ContentRequest.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ContentRequest.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    ContentRequest.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ContentRequest.first
    response.should redirect_to(admin_content_request_path(assigns[:content_request]))
  end

  it "destroy action should destroy model and redirect to index action" do
    admin_content_request = ContentRequest.first
    delete :destroy, :id => admin_content_request
    response.should redirect_to(admin_content_requests_url)
    ContentRequest.exists?(admin_content_request.id).should be_false
  end
end
