require 'spec/spec_helper'

describe MediaRequestsController do
  integrate_views

  before(:each) do
    @user = Factory(:user, :publication => 'New York Times')
    @user.has_role! :media
    controller.stubs(:current_user).returns(@user)
  end

  describe "GET new" do
    before do
      get :new
    end

    it "should render new template" do
      response.should render_template(:new)
    end

    it "should include a search form" do
      response.should have_selector(:form)
    end
  end

  describe "POST create" do
    context "with valid media request" do
      before(:each) do
        @media_request = Factory.build(:media_request, :sender_id => @user.id)
        @user.media_requests.expects(:build).returns(@media_request)
        post :create
      end

      it { response.should redirect_to(media_request_path(@media_request))}
    end

    context "with invalid media request" do
      before(:each) do
        @media_request = Factory.build(:media_request, :sender_id => @user.id, :restaurants => [])
        @user.media_requests.expects(:build).returns(@media_request)
        post :create
      end

      it { response.should render_template(:new) }
      it { response.flash[:error].should_not be_nil }
    end
  end

  describe "GET edit" do
    before do
      @media_request = Factory(:media_request, :status => 'draft', :sender => @user)
    end

    it "should render new template" do
      get :edit, :id => @media_request.id
      response.should render_template(:edit)
    end

    it "should set the default publication as the sender's publication" do
      get :edit, :id => @media_request.id
      assigns[:media_request].publication.should == @user.publication
    end
  end
end
