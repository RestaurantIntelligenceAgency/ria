module MediaRequestsHelper
  def sent_date_and_recipient_count(media_request)
    count = media_request.media_request_conversations.size
    "You sent this #{time_ago_in_words(media_request.created_at)} ago to  #{pluralize(count, 'person')}"
  end

  def response_count(media_request)
    count = media_request.reply_count
    if count == 0
      "No one has responded"
    elsif count == 1
      "1 person has responded"
    else
      "#{count} people have responded"
    end
  end

  def formatted_fields(media_request, options={})
    before_key = options[:before_key] || '<span class="fieldname">'
    after_key = options[:after_key] || "</span>"
    html_tag = options[:html_tag] || "p"
    outer_tag = options[:html_tag] || "div"

    stringified = media_request.fields.inject("") do |result, (key,value)|
      result += content_tag(html_tag, "#{before_key + key.to_s.humanize + after_key + value}\n")
    end

    content_tag(outer_tag, :class => "fields") { stringified }
  end

  def last_comment_and_date_span(comment)
     "<span class=\"commentdate\">" +
     time_ago_in_words(comment.created_at) +
     " ago</span> " +
     "#{comment.user.name} said, &ldquo;#{comment.comment}&rdquo;"
  end

  def multiple_checkbox_search(collection, search_method)
    content_tag :ul, :class => 'multiple_checkbox' do
      collection.inject("") do |result, obj|
        checked = params[:search] && params[:search][search_method] && params[:search][search_method].include?(obj.id.to_s)
        result += "<li><label>"
        result += check_box_tag("search[#{search_method}][]", obj.id, checked)
        result += obj.name
        result += "</label></li>"
      end
    end
  end

end
