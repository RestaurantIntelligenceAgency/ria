module Soapbox
  class RestaurantsController < ApplicationController
    def show      
      @restaurant = Restaurant.activated_restaurant.find_premium(params[:id])
      if @restaurant.nil?
        redirect_to(soapbox_root_path)
        return
      end
      @questions = ALaMinuteAnswer.public_profile_for(@restaurant)
      @promotions = @restaurant.promotions.all(:order => "created_at DESC", :limit => 3)
      @menu_items = @restaurant.menu_items.all(:order => "created_at DESC", :limit => 3)
    end
  end
end
