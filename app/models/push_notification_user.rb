class PushNotificationUser < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uniq_device_key
  validates_presence_of :device_tocken
end
