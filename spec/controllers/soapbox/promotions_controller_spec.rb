require_relative '../../spec_helper'

describe Soapbox::PromotionsController do
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "index action should render show template" do
  	@promotion = FactoryGirl.create(:promotion)
    get :show,:id=>@promotion.id
    response.should render_template(:show)
  end

end
