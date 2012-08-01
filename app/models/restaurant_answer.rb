# == Schema Information
# Schema version: 20120217190417
#
# Table name: restaurant_answers
#
#  id                     :integer         not null, primary key
#  restaurant_question_id :integer
#  answer                 :text
#  restaurant_id          :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class RestaurantAnswer < ActiveRecord::Base

  belongs_to :restaurant_question
  belongs_to :restaurant

  validates_presence_of :answer, :restaurant_question_id, :restaurant_id
  validates_uniqueness_of :restaurant_question_id, :scope => :restaurant_id

  named_scope :from_premium_restaurants, lambda {
    {
      :joins => { :restaurant => :subscription },
      :conditions => ["subscriptions.id IS NOT NULL AND (subscriptions.end_date IS NULL OR subscriptions.end_date >= ?)",
          Date.today]
    }
  }

  named_scope :recently_answered, :order => "restaurant_answers.created_at DESC"

  named_scope :activated_restaurants, lambda {
    {
      :joins => 'INNER JOIN restaurants as res ON `res`.id = restaurant_id ',
      :conditions => ["(res.is_activated = ?)",          true]
    }
  }


  def activity_name
    "Behind the Line"
  end

end
