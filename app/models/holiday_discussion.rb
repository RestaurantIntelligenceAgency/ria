class HolidayDiscussion < ActiveRecord::Base
  
  belongs_to :restaurant
  belongs_to :holiday
  
  acts_as_commentable
  acts_as_readable

  validates_uniqueness_of :restaurant_id, :scope => :holiday_id
  
  named_scope :with_replies, :conditions => 'comments_count > 0'
  named_scope :without_replies, :conditions => 'comments_count = 0'
  
  def self.accepted
    []
  end

  def accepted?
    false
  end
  
end
