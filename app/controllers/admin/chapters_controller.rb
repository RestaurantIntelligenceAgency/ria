class Admin::ChaptersController < Admin::AdminController

  def index
    @chapters_by_topic = Chapter.all(:order => :position).group_by(&:topic)
  end
  
  def create
    @chapter = Chapter.new(params[:chapter])
    if @chapter.save
      flash[:notice] = "Created new chapter named #{@chapter.title}"
      redirect_to admin_profile_questions_path
    else
      render :action => "show"
    end
  end
  
  def show
    @chapter = Chapter.find(params[:id])
  end
  
  def update
    @chapter = Chapter.find(params[:id])
    @chapter.update_attributes(params[:chapter])
    flash[:notice] = "Updated chapter" 
    redirect_to admin_profile_questions_path
  end
  
  def destroy
    @chapter = Chapter.find(params[:id])
    flash[:notice] = "Deleted chapter #{@chapter.title}"
    @chapter.destroy
    redirect_to admin_profile_questions_path
  end
  
  def select
    chapters = Topic.find(params[:id]).chapters
    render :update do |page|
      page.replace_html 'profile_question_chapter_id', 
          '<option value=""></option>' + options_from_collection_for_select(chapters, :id, :title)
    end
  end
  
end
