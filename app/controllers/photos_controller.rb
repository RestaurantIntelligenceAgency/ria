class PhotosController < ApplicationController
  before_filter :require_user
  before_filter :find_restaurant
  before_filter :require_account_manager_authorization, :except => [:index]

  def index
    @photos = @restaurant.photos
  end

  def edit
    @photo = @restaurant.photos.find(params[:id])
    respond_to do |format|
      format.html
      format.js   { render :action => :edit, :layout => false }
    end
  end

  def update
    @photo = @restaurant.photos.find(params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:success] = "Your changes have been saved."
      redirect_to bulk_edit_restaurant_photos_path(@restaurant)
    else
      render :action => :edit
    end
  end

  def bulk_edit
    @photos = @restaurant.photos
    @raw_photo = Photo.new
    @restaurant.photos.build
  end

  def create
    tmp = @restaurant.photos.map(&:id).compact
    if @restaurant.update_attributes(params[:restaurant])
       flash[:success] = "Your changes have been saved."
      redirect_to bulk_edit_restaurant_photos_path(@restaurant)
    else
      flash[:error] = "There were problems with the following fields"      
      @photos = @restaurant.photos
      @restaurant.photos.each{|e| e.id=nil unless tmp.include? e.id} # TODO : Hack , was not showing valid photos
      render :action => :bulk_edit
    end
  end

  def destroy
    @restaurant.photos.delete(Photo.find(params[:id]))
     respond_to do |format|
       format.html { redirect_to bulk_edit_restaurant_photos_path(@restaurant) }
       format.js   { render :nothing  => true }
     end
  end

  def reorder
    params[:photo].each_with_index do |photo_id, index|
      @restaurant.photos.find(photo_id).update_attribute(:position, index + 1)
    end
    render :nothing => true
  end

  def show_sizes
    @photo = @restaurant.photos.find(params[:id])
  end

  private

  def find_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id], :include => :photos)
  end
end
