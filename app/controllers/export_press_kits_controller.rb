class ExportPressKitsController < ApplicationController
  before_filter :find_restaurant

  def new
  end  

  def create
    if params[:export_type] == "Diner" || params[:export_type] == "Media"
      @restaurant =  Restaurant.find(params[:restaurant])
	    UserMailer.deliver_export_press_kit(params[:email],current_user,@restaurant)
	  end	
	  flash[:notice] = "Your information has been send successfully"
	  redirect_to :action => "new"  
  end



 private

  def find_restaurant
    @user = User.find(params[:user_id])
  	@restaurants = @user.restaurants
  	
  end
end