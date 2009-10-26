Factory.define :user do |f|
  f.sequence(:username) { |n| "foo#{n}" }
  f.sequence(:email)    { |n| "foo#{n}@example.com" }
  f.password 'foobar'
  f.password_confirmation { |u| u.password }
  f.confirmed_at { Time.now }
  f.association :account_type
  f.first_name { |u| u.name.split(' ').first || "John" }
  f.last_name  { |u| u.name.split(' ').last  || "Doe" }
end

Factory.define :admin, :parent => :user do |f|
  f.admin true
  f.username 'admin'
  f.first_name "Administrator"
end

Factory.define :media_user, :parent => :user do |f|
  f.publication "The Times"
end

Factory.define :status do |f|
  f.association :user
  f.message     "I just ate a cheeseburger"
end

Factory.define :twitter_user, :parent => :user do |f|
  f.atoken  'fake'
  f.asecret 'fake'
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

Factory.define :account_type do |f|
  f.name "Concierge"
end

Factory.define :page do |f|
  f.title "Page Title"
end

Factory.define :direct_message do |f|
  f.association :receiver, :factory => :user
  f.association :sender, :factory => :user
  f.title "Hello there"
  f.body  "This is a message"
end

Factory.define :media_request_conversation do |f|
  f.association :recipient, :factory => :user
  f.association :media_request
end

Factory.define :media_request do |f|
  f.association :sender, :factory => :media_user
  f.message "This is a media request message"
  f.due_date 2.days.from_now
end

Factory.define :media_request_conversation do |f|
  f.association :media_request
  f.association :recipient, :factory => :user
  f.comments_count 0
end

Factory.define :cuisine do |f|
  f.name "Mexican"
end

