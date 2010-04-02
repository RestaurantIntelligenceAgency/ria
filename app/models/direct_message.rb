# == Schema Information
# Schema version: 20100331213108
#
# Table name: direct_messages
#
#  id                     :integer         not null, primary key
#  body                   :string(255)
#  sender_id              :integer         not null
#  receiver_id            :integer         not null
#  in_reply_to_message_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#  from_admin             :boolean
#

class DirectMessage < ActiveRecord::Base
  belongs_to :receiver, :class_name => "User"
  belongs_to :sender, :class_name => "User"
  default_scope :order => 'created_at DESC'
  acts_as_readable

  named_scope :all_from_admin, :conditions => { :from_admin => true }
  named_scope :all_not_from_admin, :conditions => { :from_admin => false }

  named_scope :unread_by, lambda { |user|
     { :joins => "LEFT OUTER JOIN readings ON #{table_name}.id = readings.readable_id
       AND readings.readable_type = '#{self.to_s}'
       AND readings.user_id = #{user.id}",
       :conditions => 'readings.user_id IS NULL' }
  }


  validates_presence_of :receiver
  validates_presence_of :sender
  validates_presence_of :body

  attr_protected :from_admin

  def validate
    if sender_id == receiver_id
      errors.add :receiver, "You can't send yourself a message"
    end
  end

  def build_reply
    DirectMessage.new(
      :sender => self.receiver,
      :receiver => self.sender,
      :in_reply_to_message_id => self.id
    )
  end

  def parent_message
    DirectMessage.find(in_reply_to_message_id) if in_reply_to_message_id
  end

  def from?(user)
    sender_id == user.id
  end
end
