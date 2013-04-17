class Mediafeed::MediafeedController < ApplicationController

  before_filter :require_media_user, :only => [:directory, :directory_search]
  before_filter :require_user, :only => [:request_information,:media_subscription]
  
  def index
    redirect_to root_url(:subdomain => "spoonfeed")
  end
  
  def login
    redirect_to login_url(:subdomain => "spoonfeed")
  end
  
  def directory
    @use_search = true
    @users = User.in_soapbox_directory.all(:order => "users.last_name")

    render :template => "directory/index"
  end

  def directory_search
    directory_search_setup
    render :partial => "directory/search_results", :locals => { :users => @users }
  end

  def request_information
    if !params[:menu_item_id].blank?
      @menu_item  = MenuItem.find(params[:menu_item_id])
      @restaurant = @menu_item.restaurant
    else
      @promotion = Promotion.find(params[:promotion_id]) 
      @restaurant = @promotion.restaurant
    end  
  end

  def request_info_mail   
    if params[:promotion].blank?
      menu_item  = MenuItem.find(params[:menu_item][:id])
      title =  params[:menu_item][:name]
      detail = params[:menu_item][:description]
      user = menu_item.restaurant.media_contact
      comment = params[:comment]
      UserMailer.send_later(:deliver_request_info_mail,title,detail,user,menu_item.restaurant,comment)     
      flash[:notice] = "Request info mail has been sent!"
      redirect_to menu_items_path
    else
      promotion=Promotion.find(params[:promotion][:id])
      detail = params[:promotion][:details]
      title = params[:promotion][:title]
      user = promotion.restaurant.media_contact  
      comment = params[:comment]          
      flash[:notice] = "Request info mail has been sent!"
      UserMailer.send_later(:deliver_request_info_mail,title,detail,user,promotion.restaurant,comment)
      redirect_to promotions_path
    end     
  end 
  
  def media_subscription
    @subscriptions = current_user.media_newsletter_subscriptions
    @user = current_user
    @user.media_newsletter_setting || @user.build_media_newsletter_setting
  end

  def media_opt_update
    current_user.update_attributes(params[:user])
    flash[:notice] = "Setting saved successfully."
    redirect_to mediafeed_media_subscription_path  
  end

  def request_information_mail
  end  
 
  def add_comment

  end  

  protected

  def require_media_user
    unless current_user && (current_user.media? || current_user.admin?)
      flash[:message] = "Please log in with your media account first"
      redirect_to root_url
    end
  end

end
