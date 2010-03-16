class HolidayConversationsController < ApplicationController
  before_filter :require_user

  def show
    load_and_authorize_holiday_conversation
    build_comment
  end

  private

  def build_comment
    @comment = @holiday_conversation.comments.build(:user => current_user)
    @comment.attachments.build
    @comment_resource = [@holiday_conversation, @comment]
  end

  def load_and_authorize_holiday_conversation
    @holiday_conversation = HolidayConversation.find(params[:id])
    # unauthorized! if cannot? :read, @holiday_conversation
  end

end
