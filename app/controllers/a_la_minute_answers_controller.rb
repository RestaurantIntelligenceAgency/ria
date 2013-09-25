class ALaMinuteAnswersController < ApplicationController

  before_filter :require_user
  before_filter :require_restaurant_employee, :only => [:destroy, :bulk_edit, :edit, :update, :new, :create,:delete_attachment,:facebook_post]
  before_filter :find_activated_restaurant, :only => [:index]
  before_filter :check_employments, :only => [:bulk_edit]
  before_filter :social_redirect, :only => [:edit]
  before_filter :rotate_image, :only => [:update]
  require 'RMagick'

  def index    
    @questions = ALaMinuteAnswer.public_profile_for(@restaurant)
  end

  def destroy
    @restaurant.a_la_minute_answers.destroy(params[:id])

    if request.xhr?
      render :nothing => true
    else
      flash[:success] = "Answer removed."
      redirect_to :action => :bulk_edit
    end
  end

  def bulk_edit
    @questions = ALaMinuteQuestion.restaurants
    @answers = @restaurant.a_la_minute_answers.group_by(&:a_la_minute_question_id)
  end

  def new
    @question = ALaMinuteQuestion.find(params[:question_id])
    @answer = ALaMinuteAnswer.new
    @answer.build_social_posts
  end

  def create
    @question = ALaMinuteQuestion.find(params[:question_id])
    @answer = @restaurant.a_la_minute_answers.build(params[:a_la_minute_answer])
    if @answer.save
      change_post_at_timezone
      flash[:notice] = "Your answer has been created"
      redirect_to :action => "bulk_edit"
    else
      flash[:error] = "Your answer could not be saved. Please review the errors below."
      @answer.build_social_posts
      render :action => "new"
    end
  end

  def edit
    @answer = ALaMinuteAnswer.find(params[:id])
    @answer.build_social_posts
    @question = @answer.a_la_minute_question
  end

  def update   

    if @answer.update_attributes(params[:a_la_minute_answer])
      change_post_at_timezone
      flash[:notice] = "Your answer has been updated"
      redirect_to_social_or 'bulk_edit'
    else
      flash[:error] = "Your answer could not be saved. Please review the errors below."
      @answer.build_social_posts
      render :action => "edit"
    end
  end

  def delete_attachment
    @answer = ALaMinuteAnswer.find(params[:id])
    if params[:type]== "pdf"
      @answer.attachment = nil
    elsif params[:type]== "photo"
       @answer.photo = nil
    end  
    @answer.save
    flash[:notice] = "Deleted attachment"
    redirect_to edit_restaurant_a_la_minute_answer_path(@restaurant,@answer)
  end

  def facebook_post    
    @a_la_minute_answer = @restaurant.a_la_minute_answers.find(params[:id])
    social_post = SocialPost.find(params[:social_id])
    if @a_la_minute_answer.post_to_facebook(social_post.message)
      flash[:notice] = "Posted #{social_post.message} to Facebook page"
    else
      flash[:error] = "Not able to post #{social_post.message} to Facebook page"
    end  
    redirect_to restaurant_social_posts_path(@restaurant)
  end

  private

  def require_restaurant_employee
    @restaurant = Restaurant.find(params[:restaurant_id])
    unless @restaurant.employees.include?(current_user) || current_user.admin?
      flash[:notice] = "You must be an employee of #{@restaurant.name} to answer and edit questions"
      redirect_to restaurants_url and return
    end
    true
  end

  def find_activated_restaurant      
    @restaurant = Restaurant.find(params[:restaurant_id])
    unless @restaurant.is_activated?
      flash[:error] = "This restaurant is not activated."
      redirect_to :restaurants
    end
  end

  def social_redirect
    if params[:social]
      session[:redirect_to_social_posts] = restaurant_social_posts_page_path(@restaurant, 'newsfeed')
    end
  end

  def redirect_to_social_or(action)
    redirect_to (session[:redirect_to_social_posts].present?) ? session.delete(:redirect_to_social_posts) : { :action => action }
  end


  def change_post_at_timezone
    i = 0
    if params[:a_la_minute_answer][:facebook_posts_attributes].present?
      params[:a_la_minute_answer][:facebook_posts_attributes].each do |facebook_post|
        if facebook_post[1]["post_at"].present?          
          times = time_length(Time.parse(facebook_post[1][:post_at])-Time.zone.now,facebook_post[1][:post_at].split(" ")[1].split(":")[0])
          @answer.facebook_posts[i].update_attributes(:post_at => times)
          i+=1          
        end
      end
    elsif params[:a_la_minute_answer][:twitter_posts_attributes].present?
      params[:a_la_minute_answer][:twitter_posts_attributes].each do |twitter_post|
        if twitter_post[1]["post_at"].present?       
          times = time_length(Time.parse(twitter_post[1][:post_at])-Time.zone.now,twitter_post[1][:post_at].split(" ")[1].split(":")[0])
          @answer.twitter_posts[i].update_attributes(:post_at => times)
          i+=1
        end
      end
    end
  end

  def rotate_image
    @answer = ALaMinuteAnswer.find(params[:id])
    @question = @answer.a_la_minute_question
    if params[:angle] != ""
      # if params[:a_la_minute_answer][:photo]
        # source_image = Magick::ImageList.new(params[:a_la_minute_answer][:photo].url)
      # else
        source_image = Magick::ImageList.new(@answer.photo.url)
        file = Tempfile.new(['hello', '.jpg'])
        params[:a_la_minute_answer][:photo]=file
      # end
      image   = source_image.rotate(params[:angle].to_i)
      image.write(params[:a_la_minute_answer][:photo].path)
      params[:a_la_minute_answer].delete("angle")
    end
  end
end
