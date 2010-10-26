class Soapbox::ProfilesController < Soapbox::SoapboxController
  before_filter :get_user, :check_access

  def show
    # Is the current user following this person?
    @following = current_user.followings.first(:conditions => {:friend_id => @user.id}) if current_user
    @latest_statuses = @user.statuses.all(:limit => 5)
    load_past_features
    render :template => 'users/show'
  end

  private

  def get_user
    if params[:username]
      @user = User.find_by_username(params[:username], :include => [:followings])
      raise ActiveRecord::RecordNotFound, "Couldn't find User with username=#{params[:username]}" if @user.nil?
    else
      @user = User.find(params[:id], :include => [:followings])
    end
  end
  
  def check_access
    unless @user.linkable_profile?
      flash[:error] = "This user doesn't have a published profile yet."
      redirect_to soapbox_root_path
    end
  end

end
