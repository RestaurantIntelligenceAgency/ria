class UserMailer < ActionMailer::Base
  default_url_options[:host] = DEFAULT_HOST

  def signup(user = nil, sent_at = Time.now)
    if user
      from       'accounts@restaurantintelligenceagency.com'
      recipients user.email
      sent_on    sent_at
      subject    'Welcome to SpoonFeed! Please confirm your account'
      body       :user => user
    end
  end
  
  def password_reset_instructions(user)
    from          'accounts@restaurantintelligenceagency.com'
    recipients    user.email
    sent_on       Time.now
    subject       "SpoonFeed: Password Reset Instructions"
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
  
  def media_request_notification(request)
    from       'notifications@restaurantintelligenceagency.com'
    recipients request.recipients.map(&:email)
    sent_on    Time.now
    subject    "MediaFeed: You have a Media Request"
    body       :sender => request.sender
  end
end
