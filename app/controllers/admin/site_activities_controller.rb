class Admin::SiteActivitiesController < Admin::AdminController

  def index
    @activities = SiteActivity.all(:order => "created_at DESC").paginate(:page => params[:page])
  end

end
