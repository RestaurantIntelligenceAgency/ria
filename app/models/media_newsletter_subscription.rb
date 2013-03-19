class MediaNewsletterSubscription < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :media_newsletter_subscriber, :class_name => "User"  ,:foreign_key => "media_newsletter_subscriber_id"
  after_create :add_subscription_to_mailchimp
  after_destroy :remove_subscription_from_mailchimp
  include ActionController::UrlWriter
  default_url_options[:host] = DEFAULT_HOST

  def self.send_newsletters_to_media
    for mediaNewsletterSubscription in MediaNewsletterSubscription.find(:all,:group => "media_newsletter_subscriber_id")
      mediaNewsletterSubscription.send_later(:send_newsletter_to_media_subscribers,mediaNewsletterSubscription.media_newsletter_subscriber)
    end
  end


  def send_newsletter_to_media_subscribers subscriber
    if subscriber.media_newsletter_setting.blank? || (subscriber.media_newsletter_setting.opt_out )
      mc = MailchimpConnector.new
      campaign_id = \
      mc.client.campaign_create(:type => "regular",
                                :options => { :list_id => mc.mailing_list_id,
                                              :subject => "Restaurant's Newsletter",
                                              :from_email => subscriber.email,
                                              :to_name => "*|FNAME|*",
                                              :from_name => "Restaurant Intelligence Agency",
                                              :generate_text => true },
                                 :segment_opts => { :match => "all",
                                                    :conditions => [{ :field => "email",
                                                                      :op => "eq",
                                                                      :value => "eric@restaurantintelligenceagency.com"},
                                                                      { :field => "email",
                                                                      :op => "eq",
                                                                      :value => "nishant.v@cisinlabs.com"}]},
                                :content => { :url => media_user_newsletter_subscription_restaurants_url({:id=>subscriber.id}) })
      # send campaign
      mc.client.campaign_send_now(:cid => campaign_id)
    end  
  end

  def self.menu_items(restaurants)
    #menu_items = MenuItem.find_by_sql("SELECT GROUP_CONCAT(result_view.item SEPARATOR ',') as menu_ids FROM  (SELECT  SUBSTRING_INDEX(GROUP_CONCAT( DISTINCT  `id` SEPARATOR ',' ) ,',',3) as item FROM `menu_items` GROUP BY `restaurant_id` HAVING  `restaurant_id` IN (#{restaurants.join(',')}) ORDER BY  `created_at` DESC) result_view").first.menu_ids
    #MenuItem.find(menu_items.split(",")) unless menu_items.nil? # TODO Need to workon this Query
    menu_items = []
    restaurants.each do |restaurant|      
      menu_items.push(restaurant.menu_items.all(:order=>"created_at desc" ,:limit=>3))
    end      
    menu_items.flatten.compact
  end

  def self.menus(restaurants)
    menus = []
    restaurants.each do |restaurant|      
      menus.push(restaurant.menus.all(:order=>"created_at desc" ,:limit=>3))
    end          
    menus.flatten.compact
  end 
  
  def self.restaurant_answers(restaurants)
    restaurant_answers = []
    restaurants.each do |restaurant|      
      restaurant_answers.push(restaurant.a_la_minute_answers.all(:order=>"created_at desc" ,:limit=>3))
    end      
    restaurant_answers.flatten.compact
  end

  def self.promotions(restaurants)
   promotions = []
    restaurants.each do |restaurant|      
      promotions.push(restaurant.promotions.all(:order=>"created_at desc" ,:limit=>3))
    end      
    promotions.flatten.compact
  end

  private

  def add_subscription_to_mailchimp      
      mc = MailchimpConnector.new
      unless mc.client.list_interest_groupings(:id => mc.mailing_list_id).to_s.match(/#{restaurant.mailchimp_group_name_media}/)
        mc.client.list_interest_group_add(:id => mc.mailing_list_id, :group_name => restaurant.mailchimp_group_name_media)
      end
      unless mc.client.listMembers({:id=>mc.mailing_list_id}).to_s.match(/#{media_newsletter_subscriber.email}/)
        if mc.client.list_subscribe(:id => mc.mailing_list_id, :email_address => media_newsletter_subscriber.email,
                                :merge_vars => { :groupings => [{ :name => "Your Interests",:groups => restaurant.mailchimp_group_name_media}] },
                                :replace_interests => false).to_s.match(/error/)
          mc.client.list_update_member(:id => mc.mailing_list_id, :email_address => media_newsletter_subscriber.email,
                                :merge_vars => { :groupings => [{ :name => "Your Interests",:groups => restaurant.mailchimp_group_name_media}] },
                                :replace_interests => false)

        end
      else
        mc.client.list_update_member(:id => mc.mailing_list_id, :email_address => media_newsletter_subscriber.email,
                                :merge_vars => { :groupings => [{ :name => "Your Interests",:groups => restaurant.mailchimp_group_name_media}] },
                                :replace_interests => false)

      end  
  
  end

  def remove_subscription_from_mailchimp
    groups = []
    groups << "National Newsletter"
    for subscription in media_newsletter_subscriber.media_newsletter_subscriptions
      groups << "#{subscription.restaurant.mailchimp_group_name_media}" unless subscription == self
    end
    mc = MailchimpConnector.new
    mc.client.list_update_member(:id => mc.mailing_list_id, :email_address => media_newsletter_subscriber.email,
                                 :merge_vars => { :groupings => [{ :name => "Your Interests", :groups => groups.join(",")}] },
                                 :replace_interests => true)
  end


end