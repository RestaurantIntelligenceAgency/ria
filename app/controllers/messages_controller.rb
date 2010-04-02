class MessagesController < ApplicationController
  before_filter :require_user
  before_filter :get_message_counts
  before_filter :get_messages_from_ria, :only => [:index, :ria]

  ##
  # GET /messages
  def index
  end
  
  def ria
    render :index
  end

  ##
  # GET /messages/archive
  def archive
    @messages = current_user.archived_messages
  end
  
  def private
    @messages = current_user.direct_messages
  end
  
  def staff_discussions
    @messages = current_user.discussions
  end
  
  private
  
  def get_message_counts
    @ria_message_count = current_user.messages_from_ria.size
    @private_message_count = current_user.direct_messages.size
    @discussions_count = current_user.discussions.size
  end
  
  def get_messages_from_ria
    @messages = current_user.messages_from_ria
  end
  
end
