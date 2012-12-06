class RestaurantsController < ApplicationController
  before_filter :require_user
  before_filter :authorize, :only => [:edit, :update, :select_primary_photo,
                                             :new_manager_needed, :replace_manager, :fb_page_auth,
                                             :remove_twitter, :download_subscribers, :activate_restaurant,:new_media_contact,:replace_media_contact,:fb_deauth]
  before_filter :find_restaurant, :only => [:twitter_archive, :facebook_archive, :social_archive]

  def index
    @employments = current_user.employments
  end

  def new
    @restaurant = current_user.managed_restaurants.build(params[:restaurant])
    find_or_initialize_restaurant if params[:restaurant]
  end

  def create
    @restaurant = current_user.managed_restaurants.build(params[:restaurant])
    @restaurant.media_contact = current_user
    @restaurant.sort_name = params[:restaurant][:name]
    if @restaurant.save
      flash[:notice] = "Successfully created restaurant."
      redirect_to bulk_edit_restaurant_employees_path(@restaurant)
    else
      render :add_restaurant
    end
  end

  def show
    find_activated_restaurant
    @employments = @restaurant.employments.by_position.all(
        :include => [:subject_matters, :restaurant_role, :employee])
    @questions = ALaMinuteAnswer.public_profile_for(@restaurant)[0...3]
    @promotions = @restaurant.promotions.all(:order => "created_at DESC", :limit => 5)
    @menu_items = @restaurant.menu_items.all(:order => "created_at DESC", :limit => 3)
    @trend_answer = @restaurant.admin_discussions.for_trends.with_replies.first(:order => "created_at DESC")
  end

  def edit
    @fb_user = current_facebook_user.fetch if current_facebook_user && current_user.facebook_authorized?
  rescue Mogli::Client::OAuthException, Mogli::Client::HTTPException => e
    Rails.logger.error("Unable to fetch Facebook user for restaurant editing due to #{e.message} on #{Time.now}")
  end

  def update
    if @restaurant.update_attributes(params[:restaurant])
      flash[:notice] = "Successfully updated restaurant"
      redirect_to @restaurant
    else
      flash[:error] = "We were unable to update the restaurant"
      render :edit
    end
  end

  def select_primary_photo
    if @restaurant.update_attributes(params[:restaurant])
      flash[:notice] = "Successfully updated restaurant"
      redirect_to bulk_edit_restaurant_photos_path(@restaurant)
    else
      flash[:error] = "We were unable to update the restaurant"
      render :template => "photos/edit"
    end
  end

  def new_manager_needed
  end

  def new_media_contact
  end
   
  def replace_media_contact

    unless params[:media_contact].nil?
      new_media_contact = User.find(params[:media_contact])
      old_media_contact = @restaurant.media_contact 
      old_media_contact_employment = @restaurant.employments.find_by_employee_id(@restaurant.media_contact_id)
      
      if @restaurant.update_attribute(:media_contact_id, new_media_contact.id)
        flash[:notice] = "Updated account media contact "
      else
        flash[:error] = "Something went wrong. Our worker bees will look into it."
      end

      if old_media_contact == @restaurant.manager
        redirect_to new_manager_needed_restaurant_path(@restaurant) 
      else
        if(old_media_contact != new_media_contact && old_media_contact_employment.destroy)
          flash[:notice] = "Updated account media contact & #{new_media_contact.name} is deleted."        
        else
          flash[:notice] = "Could not deleted employee, as media contact remains same. "
        end  
        redirect_to bulk_edit_restaurant_employees_path(@restaurant)
      end  
    else
      flash[:error] = "You have to select a media contact."
      redirect_to new_media_contact_restaurant_path(@restaurant) and return
    end  
  end  

  def replace_manager
    old_manager = @restaurant.manager
    old_manager_employment = @restaurant.employments.find_by_employee_id(@restaurant.manager_id)
    new_manager = User.find(params[:manager])

    if @restaurant.media_contact == old_manager
      redirect_to new_media_contact_restaurant_path(@restaurant) and return
    end 
    
    if @restaurant.update_attribute(:manager_id, new_manager.id) && old_manager_employment.destroy
      flash[:notice] = "Updated account manager to #{new_manager.name}. #{old_manager.name} is no longer an employee."
    else
      flash[:error] = "Something went wrong. Our worker bees will look into it."
    end

    redirect_to bulk_edit_restaurant_employees_path(@restaurant)
  end

  def fb_page_auth
    
    if current_facebook_user
      @page = current_facebook_user.accounts.select { |a| a.id == params[:facebook_page] }.first      
      if @page
        @restaurant.update_attributes!(:facebook_page_id => @page.id,
                                       :facebook_page_token => @page.access_token,
                                       :facebook_page_url => @page.fetch.link)
        flash[:notice] = "Added Facebook page #{@page.name} to the restaurant"
      else
        @page = current_facebook_user
        if @page
          @restaurant.update_attributes!(:facebook_page_id => @page.id,
                                       :facebook_page_token => @page.client.access_token,
                                       :facebook_page_url => @page.fetch.link)
          flash[:notice] = "Added Facebook page #{@page.name} to the restaurant"
        else  
          @restaurant.update_attributes!(:facebook_page_id => nil, :facebook_page_token => nil)
          flash[:notice] = "Cleared the Facebook page settings from your restaurant"
        end
      end
      redirect_to edit_restaurant_path(@restaurant)
    else
      flash[:notice] = "You need to login on facebook"
      redirect_to fb_auth_user_path(current_user, :restaurant_id => @restaurant.id)
    end  
  end

  def fb_deauth
      @page  = @restaurant.facebook_page.fetch if @restaurant.has_facebook_page?
      @restaurant.update_attributes!(:facebook_page_id => nil,
                                       :facebook_page_token => nil)
      flash[:notice] = "Cleared the Facebook page #{@page.name} settings from your restaurant" unless @page.blank?
      redirect_to edit_restaurant_path(@restaurant)     
  end

  def remove_twitter
    @restaurant.atoken  = nil
    @restaurant.asecret = nil
    if @restaurant.save
      flash[:message] = "Your Twitter account is no longer connected to your SpoonFeed restaurant account"
      redirect_to edit_restaurant_path(@restaurant)
    else
      render :edit
    end
  end

  def twitter_archive
  end

  def facebook_archive
  end

  def social_archive
  end

  def activate_restaurant
    if @restaurant.update_attributes(:is_activated => params[:mode])      
      flash[:notice] = params[:mode].to_i > 0  ? "Successfully activated restaurant" : "Successfully deactivated restaurant"
      redirect_to :restaurants
    else
      flash[:error] = "We were unable to update the restaurant"
      redirect_to :restaurants
    end
  end  

  def download_subscribers
    send_data(@restaurant.newsletter_subscribers.to_csv, :filename => "#{@restaurant.name} subscribers.csv")
  end

  def add_restaurant
    @restaurant = current_user.managed_restaurants.build
  end  

  def send_restaurant_request
    @restaurant = Restaurant.find(params[:id]) 
    @employment = Employment.find(:first,:conditions=>["employee_id = ? and restaurant_id = ? ",current_user ,@restaurant])

    if @restaurant && @employment.nil?
      @req = RestaurantEmployeeRequest.new({:restaurant_id=>@restaurant.id,:employee_id=>current_user.id})
      if(@req.save)
        UserMailer.deliver_employee_request(@restaurant, current_user)
        flash[:notice] = "We've contacted the restaurant manager. Thanks for setting up your account, and enjoy SpoonFeed!"
       else
        flash[:notice] = "Something went wrong or may be you already sent request to #{@restaurant.name
}."
       end
      else
        flash[:notice] = "Something went wrong or may be you already sent request to <b> #{@restaurant.name} </b>."           
    end
    redirect_to root_path
  end

  private

  def find_activated_restaurant    
    find_restaurant
    unless can?(:manage, @restaurant) || @restaurant.is_activated?
      flash[:notice] = "This restaurant is not available to view."
      redirect_to root_path and return
    end
  end

  def find_restaurant    
    @restaurant = Restaurant.find(params[:id])
  end  

  def authorize
    find_restaurant
    if (cannot? :edit, @restaurant) || (cannot? :update, @restaurant)
      flash[:error] = "You don't have permission to access that page"
      redirect_to @restaurant and return
    end
  end

  def find_or_initialize_restaurant
    
    restaurant_name = params[:restaurant][:name]    
    @restaurants = Restaurant.find(:all, :conditions => ["name like ?", "%#{restaurant_name}%"])
    if @restaurants.blank?
      flash.now[:notice] = "We couldn't find them in our system. You can add this restaurant."
      render :add_restaurant
    else        
      flash.now[:notice] = "You can send request to this restaurant."
      render :restaurant_list  
    end  
  end  


end
