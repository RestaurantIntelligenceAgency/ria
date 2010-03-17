# == Schema Information
# Schema version: 20100303182810
#
# Table name: holidays
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  date       :date
#  created_at :datetime
#  updated_at :datetime
#

require 'spec/spec_helper'

describe Holiday do
  should_have_many :admin_holiday_reminders
  should_have_many :holiday_conversations
  should_have_many :recipients, :through => :holiday_conversations
  
  it "should know how many have replied" do
    holiday = Factory(:holiday)
    holiday.reply_count.should == 0
  end
end
