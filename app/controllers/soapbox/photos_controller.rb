module Soapbox
  class PhotosController < ApplicationController
    before_filter :find_restaurant

    def show
      @photo = @restaurant.photos.find(params[:id])
    end

    private

    def find_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end
  end
end
