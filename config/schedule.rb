# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
#
# Learn more: http://github.com/javan/whenever

## I was using this for MT
# every 15.minutes do
#   command "cd /home/ria/unplugged/_mt; perl ./tools/run-periodic-tasks >> ../../mt.log"
# end


every 1.hour do
  runner 'Feed.update_all_entries!'
end

every 1.day, :at => '2:30am' do
  rake "backup:run trigger='backup-files-to-s3'"
  rake "backup:run trigger='backup-db-to-s3'"
  rake "subscriptions:mark_past_due"
  rake "subscriptions:purge_expired"
end

every 1.day, :at => '2:30am' do
  runner 'UserRestaurantVisitor.send_notification'
end

# every :tuesday, :at => "12:00pm" do
#   runner 'Restaurant.send_newsletter_preview_reminder'
# end
#every 1.day, :at => '2:30am' do
	#runner 'MediaNewsletterSubscription.send_newsletters_to_media'
#end	

every :thursday, :at => "2:00am" do
  runner 'Restaurant.send_newsletters'
end
