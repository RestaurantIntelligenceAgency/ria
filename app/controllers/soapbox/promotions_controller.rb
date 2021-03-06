class Soapbox::PromotionsController < ApplicationController

  def index
    page = params[:page] || "1"
    if params[:promotion_type_id].present?
      @promotion_type = PromotionType.find(params[:promotion_type_id])
      @promotions = Promotion.from_premium_restaurants.all(:conditions => { :promotion_type_id => params[:promotion_type_id] }, :order => "created_at DESC").paginate(:page => page, :per_page => 10)
    elsif params[:restaurant_id].present?
      @restaurant = Restaurant.find(params[:restaurant_id])
      @promotions = @restaurant.promotions.all(:order => "created_at DESC").paginate(:page => page, :per_page => 10)
    else
      @promotions = Promotion.from_premium_restaurants.all(:order => "created_at DESC").paginate(:page => page, :per_page => 10)
    end
  end

  def show
    @soapbox_keywordable_id =   params[:id]
    @soapbox_keywordable_type = 'Promotion'   
    @promotion = Promotion.find(params[:id])
    @restaurant = @promotion.restaurant.id
    @promotions = @promotion.restaurant.promotions.all(:limit=>3,:order=>"created_at DESC",:conditions=>["DATE(promotions.start_date) >= DATE(?) and promotions.id <> ?", Time.now,@promotion.id])
    @menu_items = @promotion.restaurant.menu_items.all(:limit=>3,:order=>"created_at DESC")
    @answers =  @promotion.restaurant.a_la_minute_answers.all(:limit=>3,:order => "a_la_minute_answers.created_at DESC",:conditions=>["DATE(a_la_minute_answers.created_at) = DATE(?)", Time.now])

  end

end
