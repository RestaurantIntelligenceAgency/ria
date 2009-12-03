module Admin::MediaRequestsHelper
  def list_and_link_replies(media_request)
    return "none" if media_request.conversations_with_comments.size == 0
    media_request.conversations_with_comments.map do |conversation|
      link_to conversation.recipient.try(:name), media_request_conversation_path(conversation)
    end.join(", ")
  end
end
