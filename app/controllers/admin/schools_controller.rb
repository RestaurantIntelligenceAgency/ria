class Admin::SchoolsController < Admin::AdminController
  def index
    @culinary_schools = School.all
    @nonculinary_schools = NonculinarySchool.all
  end
  
  def show
    @school = School.find(params[:id])
  end
  
  def new
    @school = School.new
  end
  
  def create
    @school = School.new(params[:school])
    if @school.save
      flash[:notice] = "Successfully created school."
      redirect_to admin_schools_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @school = School.find(params[:id])
  end
  
  def update
    @school = School.find(params[:id])
    if @school.update_attributes(params[:school])
      flash[:notice] = "Successfully updated school."
      redirect_to [:admin, @school]
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @school = School.find(params[:id])
    @school.destroy
    flash[:notice] = "Successfully destroyed school."
    redirect_to admin_schools_url
  end
end
