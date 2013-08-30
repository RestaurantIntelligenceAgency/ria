# == Schema Information
#
# Table name: newsletter_subscriptions
#
#  id                       :integer         not null, primary key
#  restaurant_id            :integer
#  newsletter_subscriber_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#  share_with_restaurant    :boolean         default(FALSE)
#

class NewsletterSubscription < ActiveRecord::Base

  belongs_to :restaurant
  belongs_to :newsletter_subscriber

  validates_uniqueness_of :newsletter_subscriber_id, :scope => :restaurant_id


#  after_create :add_subscription_to_mailchimp
#  after_destroy :remove_subscription_from_mailchimp



  def self.menu_items(restaurants)
    menu_items = []
    menu_items = MenuItem.find(:all,:conditions=>["restaurant_id in (?) and (created_at >= ? OR updated_at >= ?) ",restaurants.compact.map(&:id),get_limit_day.day.ago.beginning_of_day,get_limit_day.day.ago.beginning_of_day],:order=>"updated_at desc",:limit=>3)      
    menu_items.flatten.compact
  end

  def self.promotions(restaurants)
    promotions = []
    promotions = Promotion.find(:all,:conditions=>["restaurant_id in (?) and (created_at >= ? OR updated_at >= ?) ",restaurants.compact.map(&:id),get_limit_day.day.ago.beginning_of_day,get_limit_day.day.ago.beginning_of_day],:order=>"updated_at desc",:limit=>3)
    promotions.flatten.compact    
  end

  def self.newsletter_menus(restaurants)
    menus = []
    menus = Menu.find(:all,:conditions=>["restaurant_id in (?) and (created_at >= ? OR updated_at >= ?) ",restaurants.map(&:id),1.day.ago.beginning_of_day,1.day.ago.beginning_of_day],:order=>"updated_at desc",:limit=>3) 
    menus.flatten.compact
  end

  def self.fact_sheets(restaurants)
    fact_sheets = []
    fact_sheets = RestaurantFactSheet.find(:all,:conditions=>["restaurant_id in (?) and (created_at >= ? OR updated_at >= ?) ",restaurants.map(&:id),1.day.ago.beginning_of_day,1.day.ago.beginning_of_day],:order=>"updated_at desc",:limit=>3) 
    fact_sheets.flatten.compact
  end

  def self.photos(restaurants)
    photos = []
    restaurants.each do |restaurant|  
      photos.push(restaurant.photos.find(:all,:conditions=>["(created_at >= ? OR updated_at >= ?) ",1.day.ago.beginning_of_day,1.day.ago.beginning_of_day],:order=>"updated_at desc",:limit=>3))
    end      
    photos.flatten.compact
   
  end

  private

  def add_subscription_to_mailchimp

    unless newsletter_subscriber.opt_out?
      mc = MailchimpConnector.new
      unless mc.client.list_interest_groupings(:id => mc.mailing_list_id).to_s.match(/#{restaurant.mailchimp_group_name}/)
        mc.client.list_interest_group_add(:id => mc.mailing_list_id, :group_name => restaurant.mailchimp_group_name)
      end
      unless mc.client.listMembers({:id=>mc.mailing_list_id}).to_s.match(/#{newsletter_subscriber.email}/)
        if mc.client.list_subscribe(:id => mc.mailing_list_id, :email_address => newsletter_subscriber.email,
                                :merge_vars => { :groupings => [{ :name => "Your Interests",:groups => restaurant.mailchimp_group_name}] },
                                :replace_interests => false).to_s.match(/error/)
          mc.client.list_update_member(:id => mc.mailing_list_id, :email_address => newsletter_subscriber.email,
                                :merge_vars => { :groupings => [{ :name => "Your Interests",:groups => restaurant.mailchimp_group_name}] },
                                :replace_interests => false)

        end
      else
        mc.client.list_update_member(:id => mc.mailing_list_id, :email_address => newsletter_subscriber.email,
                                :merge_vars => { :groupings => [{ :name => "Your Interests",:groups => restaurant.mailchimp_group_name}] },
                                :replace_interests => false)

      end  
      
      #client.list_update_member old method
      end
  end

  def remove_subscription_from_mailchimp
    groups = []
    groups << "National Newsletter" if newsletter_subscriber.receive_soapbox_news?
    for subscription in newsletter_subscriber.newsletter_subscriptions
      groups << "#{subscription.restaurant.mailchimp_group_name}" unless subscription == self
    end

    mc = MailchimpConnector.new
    mc.client.list_update_member(:id => mc.mailing_list_id, :email_address => newsletter_subscriber.email,
                                 :merge_vars => { :groupings => [{ :name => "Your Interests", :groups => groups.join(",")}] },
                                 :replace_interests => true)
  end

  def self.get_limit_day
    if Date::ABBR_DAYNAMES[Date.today.wday] == "Mon"
      return 2
    else
      return 1  
    end 
  end  

end
