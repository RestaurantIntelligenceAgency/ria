class Admin::QuestionRolesController < Admin::AdminController
  
  def new
    @role = QuestionRole.new
  end
  
  def create
    @role = QuestionRole.new(params[:question_role])
    if @role.save
      flash[:notice] = "Created role #{@role.name}"
    else
      render :action => "new"
    end
    redirect_to :action => "new"
  end
  
  def edit
    @role = QuestionRole.find(params[:id])
    render :action => "new"
  end
  
  def update
    @role = QuestionRole.find(params[:id])
    if @role.update_attributes(params[:question_role])
      flash[:notice] = "Saved role #{@role.name}"
    else
      render :action => "new"
    end
    redirect_to :action => "new"
  end

  def destroy
    @role = QuestionRole.find(params[:id])
    if @role.topics.count > 0
      flash[:error] = "Unable to delete roles currently assigned to topics"
    else
      flash[:notice] = "Deleted role #{@role.name}"
      @role.destroy
    end
    redirect_to :action => "new"
  end

end
