# == Users ==
Factory.define :user do |f|
  f.sequence(:username) { |n| "foo#{n}" }
  f.sequence(:email)    { |n| "foo#{n}@example.com" }
  f.password 'secret'
  f.password_confirmation { |u| u.password }
  f.confirmed_at { 1.week.ago }
  f.first_name { |u| u.name.split(' ').first || "John" }
  f.last_name  { |u| u.name.split(' ').last  || "Doe" }
end

Factory.define :twitter_user, :parent => :user do |f|
  f.atoken  'fake'
  f.asecret 'fake'
end

Factory.define :facebook_user, :parent => :user do |f|
  f.facebook_id  1234567
  f.facebook_access_token 'foobar'
end

Factory.define :admin, :parent => :user do |f|
  f.username 'admin'
  f.first_name "Administrator"
  f.role 'admin'
end

Factory.define :media_user, :parent => :user do |f|
  f.publication "The Times"
  f.role 'media'
end

Factory.define :profile do |f|
  f.association :user
end

# == Restaurants ==
Factory.define :restaurant do |f|
  f.name    "Joe's Diner"
  f.street1 "123 S State St"
  f.city    "Chicago"
  f.state   "IL"
  f.zip     "60606"
end

Factory.define :managed_restaurant, :parent => :restaurant do |f|
  f.association :manager, :factory => :user
  f.association :cuisine
  f.association :metropolitan_area
end

Factory.define :employment do |f|
  f.association :restaurant
  f.association :employee, :factory => :user
  f.primary false
end

Factory.define :assigned_employment, :parent => :employment do |f|
  f.subject_matters {|e| [e.association(:subject_matter)] }
  f.restaurant_role {|e|  e.association(:restaurant_role) }
end

Factory.define :status do |f|
  f.association :user
  f.message     "I just ate a cheeseburger"
  f.created_at { 2.days.ago }
end

Factory.define :date_range do |f|
  f.name "Holiday"
  f.start_date Date.parse('2009-01-01')
  f.end_date   Date.parse('2009-12-31')
end

Factory.define :coached_status_update do |f|
  f.message "Where was the last place you ate?"
  f.association :date_range
end

Factory.define :event do |f|
  f.title "Summer Dinner"
  f.start_at Date.today.beginning_of_day
  f.end_at Date.today.end_of_day
  f.location "the bar"
  f.association :restaurant
  f.category "Promotion"
end

Factory.define :admin_event, :parent => "event" do |f|
  f.title "Summer Benefit"
  f.start_at Date.today.beginning_of_day
  f.end_at Date.today.end_of_day
  f.location "the restaurant"
  f.category "Charity"
end

Factory.define :question_role do |f|
  f.name "Cuisine"
  f.restaurant_roles { [Factory(:restaurant_role)] }
end

Factory.define :topic do |f|
  f.title "Professional background"
  f.question_roles { [Factory(:question_role)] }
end

Factory.define :chapter do |f|
  f.title "Early career"
  f.association :topic
end

Factory.define :profile_question do |f|
  f.title "Where did you train?"
  f.chapters { [Factory(:chapter)] }
end

# == Lookup Tables ==

Factory.define :cuisine do |f|
  f.name "Mexican"
end

Factory.define :restaurant_role do |f|
  f.name "Chef"
end

Factory.define :james_beard_region do |f|
  f.name "Midwest"
  f.description "IN IL OH"
end

Factory.define :metropolitan_area do |f|
  f.name "Chicago IL"
end

Factory.define :subject_matter do |f|
  f.name "Beverages"
end

Factory.define :page do |f|
  f.title   "Page Title"
  f.slug    {"page-title"}
  f.content {"This is the page content"}
end

Factory.define :direct_message do |f|
  f.association :receiver, :factory => :user
  f.association :sender, :factory => :user
  f.body  "This is a message"
end

# == Media Requests ==
Factory.define :media_request do |f|
  f.association :sender, :factory => :media_user
  f.association :subject_matter
  f.message "This is a media request message"
  f.due_date 2.days.from_now
  f.restaurants {|mr| [mr.association(:restaurant)]}
end

Factory.define :sent_media_request, :parent => :media_request do |f|
  f.status 'approved'
end

Factory.define :pending_media_request, :parent => :media_request do |f|
  f.association :employment_search
end


Factory.define :media_request_discussion do |f|
  f.association :media_request
  f.association :restaurant
  f.comments_count 0
end

# == Feeds ==
Factory.define :feed do |f|
  f.title "Example Blog RSS"
  f.url "http://www.example.com"
  f.feed_url "http://feeds.neotericdesign.com/neotericdesign"
  f.etag "fake_etag_avkl"
  f.no_entries true
end

Factory.define :feed_category do |f|
  f.name "Food Blogs"
end

Factory.define :feed_entry do |f|
  f.sequence(:guid) { |n| "guid_#{n}" }
  f.title   "Pork is best with salmon"
  f.summary "Although pork is uncommon, lorem ipsum."
  f.url     { "http://www.example.com/posts/2" }
  f.published_at { 2.days.ago }
  f.feed    {|e| e.association(:feed) }
end

Factory.define :feed_subscription do |f|
  f.association :user
  f.association :feed
end

Factory.define :discussion do |f|
  f.title "My Discussion"
  f.body  "Lorem ipsum dolor sit amet, consectetur adipisicing elit."
end

Factory.define :comment do |f|
  f.comment "This is my comment"
  f.user    {|c| c.association :user }
end

Factory.define :discussion_comment, :parent => :comment do |f|
  f.commentable {|c| c.association :discussion }
  f.commentable_type { "Discussion" }
end

# == Admin Messages ==
Factory.define :admin_message, :class => Admin::Message do |f|
  f.message "This is an admin message"
  f.scheduled_at { 1.day.ago }
end

Factory.define :qotd, :class => Admin::Qotd do |f|
  f.message "Today's question is: ..."
  f.scheduled_at { 1.day.ago }
end

Factory.define :announcement, :class => Admin::Announcement do |f|
  f.message "We're all taking tomorrow off."
  f.scheduled_at { 1.day.ago }
end

Factory.define :pr_tip, :class => Admin::PrTip do |f|
  f.message "Go forth and be awesome!"
  f.scheduled_at { 1.day.ago }
end

Factory.define :holiday_reminder, :class => Admin::HolidayReminder do |f|
  f.message "This is a holiday reminder"
  f.association :holiday
end

Factory.define :admin_conversation, :class => Admin::Conversation do |f|
  f.association :recipient, :factory => :user
  f.association :admin_message
end

Factory.define :admin_discussion do |f|
  f.discussionable {|d| d.association :trend_question }
  f.discussionable_type { "TrendQuestion" }
  f.restaurant {|d| d.association :restaurant }
end

# == Holidays ==
Factory.define :holiday do |f|
  f.name "Valentine's Day"
  f.date Date.today
  f.association :employment_search
end

Factory.define :holiday_conversation do |f|
  f.association :recipient, :factory => :employment
  f.association :holiday
end

Factory.define :holiday_discussion do |f|
  f.association :restaurant
  f.association :holiday
  f.accepted false
end

Factory.define :holiday_discussion_reminder do |f|
  f.association :holiday_discussion
  f.association :holiday_reminder
end

# == Trend Question ==
Factory.define :trend_question do |f|
  f.subject "What is the haps?"
  f.body    "Boo-ya"
  f.scheduled_at { 2.days.ago }
  f.association :employment_search
end

Factory.define :employment_search do |f|
  f.conditions "--- \n:restaurant_name_like: neo\n"
end

Factory.define :content_request do |f|
  f.subject "RFP"
  f.body    "Please send your proposal"
  f.scheduled_at { 1.day.ago }
  f.association :employment_search
end

Factory.define :soapbox_entry do |f|
  f.association :featured_item, :factory => :qotd
  f.published_at Time.now
end