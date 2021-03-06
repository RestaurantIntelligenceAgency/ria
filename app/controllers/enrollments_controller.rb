class EnrollmentsController < ApplicationController

  before_filter :require_user

  def new
    @profile = User.find(params[:user_id]).profile
    @enrollment = @profile.enrollments.build
    render :layout => false if request.xhr?
  end

  def create
    @profile = User.find(params[:user_id]).profile
    @enrollment = @profile.enrollments.build(params[:enrollment])

    respond_to do |wants|
      if @enrollment.save
        wants.html { redirect_to edit_user_profile_path(:user_id => @profile.user.id) }
        wants.json do render :json => {
            :html => render_to_string(:partial => '/enrollments/enrollment.html.erb', :locals => {:enrollment => @enrollment}),
            :enrollment => @enrollment.to_json
          }
        end
      else
        wants.html { render :new }
        wants.json { render :json => render_to_string(:partial => 'form.html.erb'), :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    render :layout => false if request.xhr?
  end

  def update
    @enrollment = Enrollment.find(params[:id])

    respond_to do |wants|
      if @enrollment.update_attributes(params[:enrollment])
        wants.html { redirect_to edit_user_profile_path(:user_id => @enrollment.profile.user.id) }
        wants.json { render :json => {
          :html => render_to_string(:partial => '/enrollments/enrollment.html.erb', :locals => {:enrollment => @enrollment}),
          :enrollment => @enrollment.to_json
        } }
      else
        wants.html { render :new }
        wants.json { render :json => render_to_string(:partial => 'form.html.erb'), :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @enrollment = Enrollment.find(params[:id])
    if @enrollment.destroy
      respond_to do |wants|
        wants.html { redirect_to edit_user_profile_path(:user_id => @enrollment.profile.user.id, :anchor => "profile-extended") }
        wants.js { render :nothing => true }
      end
    end
  end

end
