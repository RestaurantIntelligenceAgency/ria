# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def button_tag(content = "Submit", options = {}, escape = true, &block)
    options.reverse_merge!(:type => 'submit')
    content_tag(:button, content, options, escape, &block) 
  end
  
  def date_for(date)
    if date < 1.day.ago
      date.strftime('%b %d, %Y')
    else
      time_ago_in_words(date) + ' ago'
    end
  end
  
  def fb_login_link(url=root_path)
    link_to_function image_tag("connect.gif"), 
        "FB.login(function() {	window.location.href='#{url}'},{perms: 'offline_access,publish_stream,email'});", 
        :class => "facebook_login"
  end

end
