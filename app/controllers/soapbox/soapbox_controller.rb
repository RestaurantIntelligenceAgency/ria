class Soapbox::SoapboxController < ApplicationController
  
  before_filter :load_past_features, :only => [:index, :directory]
  
  layout 'soapbox'
  
  def index
    @home = true
    @slides = SoapboxSlide.all(:order => "position", :limit => 4)
    @promos = SoapboxPromo.all(:order => "position", :limit => 3)
  end

  def directory
    if params[:specialty_id]
      @specialty = Specialty.find(params[:specialty_id])
      @users = User.profile_specialties_id_eq(params[:specialty_id]).all(:order => "users.last_name", 
        :conditions => { :premium_account => true }).uniq
    elsif params[:cuisine_id]
      @cuisine = Cuisine.find(params[:cuisine_id])
      @users = User.profile_cuisines_id_eq(params[:cuisine_id]).all(:order => "users.last_name", 
        :conditions => { :premium_account => true }).uniq
    else
      params[:search] = { :premium_account_equals => true }
      directory_search_setup
      
      @use_search = true
      @users_for_search = User.by_last_name.all(:conditions => { :premium_account => true })
      @restaurants_for_search = @users_for_search.map(&:restaurants).flatten.compact.uniq.sort { |a,b| a.sort_name <=> b.sort_name }
    end
    
    render :template => "directory/index"
  end
  
  def directory_search
    params[:search].present? ? 
        params[:search].merge(:premium_account_equals => true) : 
        params[:search] = { :premium_account_equals => true }
    
    directory_search_setup
    render :partial => "directory/search_results"
  end

end
