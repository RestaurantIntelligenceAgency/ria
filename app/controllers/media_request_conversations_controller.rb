class MediaRequestConversationsController < ApplicationController
  def show
    @media_request_conversation = MediaRequestConversation.find(params[:id])
    @comments = @media_request_conversation.comments.reject(&:new_record?)
    @comment = @media_request_conversation.comments.build
    @comment.user = current_user
  end

  def update
    @media_request_conversation = MediaRequestConversation.find(params[:id])
    if @media_request_conversation.update_attributes(params[:media_request_conversation])
      flash[:notice] = "Cool. That worked!"
      redirect_to @media_request_conversation
    else
      render :show
    end
  end
end
