# == Schema Information
# Schema version: 20110831230326
#
# Table name: users
#
#  id                    :integer         not null, primary key
#  username              :string(255)
#  email                 :string(255)
#  crypted_password      :string(255)
#  password_salt         :string(255)
#  perishable_token      :string(255)
#  persistence_token     :string(255)     not null
#  created_at            :datetime
#  updated_at            :datetime
#  confirmed_at          :datetime
#  last_request_at       :datetime
#  atoken                :string(255)
#  asecret               :string(255)
#  avatar_file_name      :string(255)
#  avatar_content_type   :string(255)
#  avatar_file_size      :integer
#  avatar_updated_at     :datetime
#  first_name            :string(255)
#  last_name             :string(255)
#  publication           :string(255)
#  role                  :string(255)
#  facebook_id           :string(255)
#  facebook_access_token :string(255)
#  facebook_page_id      :string(255)
#  facebook_page_token   :string(255)
#  premium_account       :boolean
#  visible               :boolean         default(TRUE)
#  national              :boolean
#  mediafeed_visible     :boolean         default(TRUE)
#  notification_email    :string(255)
#

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validates_format_of_login_field_options = { :with => /^[a-zA-Z0-9\-\_ ]+$/,
      :message => "'%{value}' is not allowed. Usernames can only contain letters, numbers, and/or the '-' symbol" }
    c.disable_perishable_token_maintenance = true
  end

  include TwitterAuthorization
  include UserMessaging

  has_many :statuses, :dependent => :destroy

  has_many :followings, :foreign_key => 'follower_id', :dependent => :destroy
  has_many :friends, :through => :followings
  has_many :inverse_followings, :class_name => "Following", :foreign_key => 'friend_id', :dependent => :destroy
  has_many :followers, :through => :inverse_followings, :source => :follower

  has_many :direct_messages, :foreign_key => "receiver_id", :dependent => :destroy
  has_many :sent_direct_messages, :class_name => "DirectMessage", :foreign_key => "sender_id", :dependent => :destroy

  ## Sent, not received media requests
  has_many :media_requests, :foreign_key => 'sender_id'

  has_many :employments, :foreign_key => "employee_id", :dependent => :destroy, :conditions => "restaurant_id is not null"
  has_many :restaurants, :through => :employments
  has_many :managed_restaurants, :class_name => "Restaurant", :foreign_key => "manager_id"
  has_many :manager_restaurants, :source => :restaurant, :through => :employments, :conditions => ["employments.omniscient = ?", true]
  has_many :restaurant_roles, :through => :employments

  has_one :default_employment, :foreign_key => "employee_id", :dependent => :destroy

  ## For search
  has_many :all_employments, :foreign_key => "employee_id", :class_name => "Employment"
  has_many :all_restaurant_roles, :through => :all_employments, :source => "restaurant_role"

  has_many :discussion_seats, :dependent => :destroy
  has_many :discussions, :through => :discussion_seats

  has_many :posted_discussions, :class_name => "Discussion", :foreign_key => "poster_id"

  has_many :admin_conversations, :class_name => "Admin::Conversation", :foreign_key => 'recipient_id'

  has_many :solo_discussions, :through => :default_employment, :dependent => :destroy

  has_many :feed_subscriptions, :dependent => :destroy
  has_many :feeds, :through => :feed_subscriptions

  has_many :readings, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  has_one :profile, :dependent => :destroy
  has_many :profile_answers, :dependent => :destroy

  has_one :invitation, :foreign_key => "invitee_id"
  has_subscription

  validates_presence_of :email

  has_and_belongs_to_many :metropolitan_areas

  attr_accessor :send_invitation, :agree_to_contract, :invitation_sender, :password_reset_required

  # Attributes that should not be updated from a form or mass-assigned
  attr_protected :crypted_password, :password_salt, :perishable_token, :persistence_token, :confirmed_at, :admin=, :admin

  accepts_nested_attributes_for :profile, :default_employment

  has_attached_file :avatar,
                    :default_url => "/images/default_avatars/:style.png",
                    :styles => { :small => "100x100>", :thumb => "50x50#", :tiny => "20x20#" }

  validates_attachment_content_type :avatar,
      :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"],
      :message => "Please upload a valid image type: jpeg, gif, or png", :if => :avatar_file_name

  validates_exclusion_of :publication,
                         :in => %w( freelance Freelance ),
                         :message => "'%{value}' is not allowed"

  validates_acceptance_of :agree_to_contract

  validates_presence_of :facebook_page_token, :if => Proc.new { |user| user.facebook_page_id }
  validates_presence_of :facebook_page_id, :if => Proc.new { |user| user.facebook_page_token }

  after_create :deliver_invitation_message!, :if => Proc.new { |user| user.send_invitation }

  named_scope :media, :conditions => {:role => 'media'}
  named_scope :admin, :conditions => {:role => 'admin'}

  named_scope :for_autocomplete, :select => "first_name, last_name", :order => "last_name ASC", :limit => 15
  named_scope :by_last_name, :order => "LOWER(last_name) ASC"

  named_scope :active, :conditions => "last_request_at IS NOT NULL"
  named_scope :visible, :conditions => ['visible = ? AND (role != ? OR role IS NULL)', true, 'media']


### Preferences ###
  preference :hide_help_box, :default => false
  preference :receive_email_notifications, :default => true
  preference :publish_profile, :default => true

### Roles ###
  def admin?
    return @is_admin if defined?(@is_admin)
    @is_admin = has_role?(:admin)
  end
  alias :admin :admin?

  def media?
    return @is_media if defined?(@is_media)
    @is_media = has_role?(:media)
  end
  alias :media :media?

  def admin=(bool)
    TRUE_VALUES.include?(bool) ? has_role!("admin") : has_no_role!(:admin)
  end

  def media=(bool)
    TRUE_VALUES.include?(bool) ? has_role!("media") : has_no_role!(:media)
  end

  def has_role?(_role)
    role == _role.to_s.downcase
  end

  def has_role!(role)
    update_attribute(:role, role.to_s)
  end

  def has_no_role!(role = nil)
    update_attribute(:role, nil)
  end

  def self.find_premium(id)
    possibility = find_by_id(id)
    if possibility.premium_account then possibility else nil end
  end

  def following?(otheruser)
    friends.include?(otheruser)
  end

  ## Employment things
  def restaurants_where_manager
    [managed_restaurants.all, manager_restaurants.all].compact.flatten.uniq
  end

  def allowed_subject_matters
    allsubjects = SubjectMatter.all
    admin? ? allsubjects : allsubjects.reject(&:admin_only?)
  end

  def coworkers
    coworker_ids = restaurants.map(&:employee_ids).flatten.uniq
    User.find(coworker_ids)
  end

  def primary_employment
    self.employments.primary.first || self.employments.first || self.default_employment
  end

  def nonprimary_employments
    employments - [primary_employment]
  end

  # do they have the setup needed for Behind the Line (profile questions)?
  def btl_enabled?
    primary_employment.present? && primary_employment.restaurant_role.present?
  end

  def restaurant_names
    if employments.blank?
      primary_employment.try(:solo_restaurant_name)
    elsif employments.count == 1
      primary_employment.restaurant.try(:name)
    else
      employments.all(:order => '"primary" DESC', :include => :restaurant).map{|e| e.restaurant.try(:name) }.to_sentence
    end
  end

  def post_to_soapbox?
    primary_employment.try(:post_to_soapbox)
  end

### Convenience methods for getting/setting first and last names ###
  def name
    @name ||= [first_name, last_name].compact.join(' ')
  end

  def name=(_name)
    name_parts = _name.split(' ', 2)
    self.first_name = name_parts.shift
    self.last_name = name_parts.pop
  end

  def name_or_username
    name.blank? ? username : name
  end

  def to_label
    name_or_username
  end

  def confirmed?
    confirmed_at.present?
  end
  alias :confirmed :confirmed?

  def confirmed=(value)
    self.confirmed_at = TRUE_VALUES.include?(value) ? Time.now : nil
  end

  def confirm!
    self.confirmed_at = Time.now
    self.save
  end

  def completed_setup?
    self.profile.present? && self.primary_employment.present?
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.deliver_password_reset_instructions(self)
  end

  def has_feeds?
    !feeds.blank?
  end

  def chosen_feeds(dashboard = false)
    return feeds.all(:limit => (dashboard ? 2 : nil)) if has_feeds?
    nil
  end

  # For User.to_csv export
  def export_columns(format = nil)
    %w[username first_name last_name email]
  end

  def self.find_by_smart_case_login_field(user_login)
    # login like an email address ?
    if user_login =~ Authlogic::Regex.email
      first(:conditions => { :email => user_login })
    else
      first(:conditions => { :username => user_login })
    end
  end

  def self.find_by_login(login)
    find_by_smart_case_login_field(login)
  end

  def self.find_by_name(_name)
    name_parts = _name.split(' ')
    find_by_first_name_and_last_name(name_parts.shift, name_parts.pop)
  end

  def self.find_all_by_name(_name)
    namearray = _name.split(" ")
    if namearray.length > 1
      first_name_begins_with(namearray.first).last_name_begins_with(namearray.last)
    else
      first_name_or_last_name_begins_with(namearray.first)
    end
  end

  def self.receive_email_notifications
    User.with_preferences(:receive_email_notifications => true)
  end

  def self.in_soapbox_directory
    active.visible.with_premium_account.with_preferences(:publish_profile => true).by_last_name
  end

  def self.in_spoonfeed_directory
    active.visible.by_last_name
  end

  def deliver_invitation_message!(reset_token = true)
    @send_invitation = nil
    reset_perishable_token! if reset_token
    logger.info( "Delivering invitation email to #{email}" )
    UserMailer.deliver_new_user_invitation!(self, invitation_sender)
  end

  def email_for_content
    notification_email.present? ? notification_email : email
  end

  # Facebook !!!

  def connect_to_facebook_user(fb_id)
    update_attributes(:facebook_id => fb_id)
  end

  def facebook_authorized?
    facebook_id.present? and facebook_access_token.present?
  end

  def facebook_user
    if facebook_id and facebook_access_token
      @facebook_user ||= Mogli::User.new(:id => facebook_id, :client => Mogli::Client.new(facebook_access_token))
    end
  end

  def has_facebook_page?
    facebook_page_id.present? and facebook_page_token.present?
  end

  def facebook_page
    @page ||= Mogli::Page.new(:id => facebook_page_id, :client => Mogli::Client.new(facebook_page_token))
  end

  # Behind the line

  def profile_questions
    self.primary_employment.present? ? ProfileQuestion.for_user(self) : []
  end

  def topics
    self.primary_employment.present? ? Topic.for_user(self) : []
  end

  def published_topics
    topics.select { |t| t.published?(self) }
  end

  # Profile elements

  def cuisines
    profile.present? ? profile.cuisines : []
  end

  def specialties
    profile.present? ? profile.specialties : []
  end

  def james_beard_region
    profile.present? ? profile.james_beard_region : nil
  end

  def metropolitan_area
    profile.present? ? profile.metropolitan_area : nil
  end

  def phone_number
    if profile.present? then profile.cellnumber else nil end
  end

  def public_phone_number
    return nil if profile.blank? || !profile.display_cell_public?
    profile.cellnumber
  end

  def linkable_profile?
    self.prefers_publish_profile? && self.premium_account?
  end

  ## Subscriptions
  def braintree_contact
    self
  end

  def recently_upgraded?
    self.subscription.try(:start_date).try(:>, 1.week.ago.to_date)
  end

  # a string which can be used in the disposable part of the email to track and authenticate user
  def cloudmail_id(message)
    token = cloudmail_token(message)
    return "#{id}-#{token}-#{message.short_title}-#{message.id}"
  end
  
  # generates a one way hash used in the authentication for cloudmailin
  def cloudmail_token(message)
    Digest::SHA1.hexdigest("#{message.id}-#{id}-#{CLOUDMAIL_SEED}-#{email}")[0..8]
  end

  # checks the cloudmail_token is valid
  def validate_cloudmail_token!(token, message)
    unless token == cloudmail_token(message)
      throw 'invalid cloudmail token'
    end
  end

  # check if user is individual
  # or associated with a restaurants
  def individual?
    employments.blank?
  end

  # check if user associated with restaurants
  # has at least one filled role
  def has_restaurant_role?
    !self.employments.first(:conditions => 'restaurant_role_id IS NOT NULL').nil?
  end

  # user permission for receiving front burner content
  def front_burner_status
    status = if self.post_to_soapbox?
      :granted
    elsif self.individual?
      :individual_denied
    else
      :restaurant_denied
    end

    return status
  end

  def self.extended_find(keyword)
    # when searchlogic will be updated, instead of all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # one can use id_not_in(users.map(&:id))

    # USER: first_name, last_name, role
    users = User.in_soapbox_directory.first_name_or_last_name_or_role_like(keyword)
    # USER->PROFILE: headline, summary, hometown, current_residence
    users += User.in_soapbox_directory.
      profile_headline_or_profile_summary_or_profile_hometown_or_profile_current_residence_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->METROPOLITAN AREA: name
    users += User.in_soapbox_directory.profile_metropolitan_area_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->CUISINES: name
    users += User.in_soapbox_directory.profile_cuisines_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->SPECIALTIES: name
    users += User.in_soapbox_directory.profile_specialties_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->RESAURANTS: name
    users += User.in_soapbox_directory.restaurants_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->AWARDS: name
    users += User.in_soapbox_directory.profile_awards_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->EMPLOYMENT->RESTAURANT_ROLE: name
    users += User.in_soapbox_directory.employments_restaurant_role_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->CULINARY_JOB: restaurant_name, title, chef_name, cuisine, notes
    users += User.in_soapbox_directory.profile_culinary_jobs_restaurant_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_culinary_jobs_title_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_culinary_jobs_chef_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_culinary_jobs_cuisine_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_culinary_jobs_notes_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->NONCULINARY_JOB: company, title, chef_name, cuisine, notes
    users += User.in_soapbox_directory.profile_nonculinary_jobs_company_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_nonculinary_jobs_title_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_nonculinary_jobs_responsibilities_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->ENROLLMENTS->SCHOOLS: name
    users += User.in_soapbox_directory.profile_schools_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->ENROLLMENTS: degree, focus, scholarships
    users += User.in_soapbox_directory.profile_enrollments_degree_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_enrollments_focus_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_enrollments_scholarships_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->NONCULINARY_ENROLLMENTS->SCHOOLS: name
    users += User.in_soapbox_directory.profile_nonculinary_schools_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->NONCULINARY_ENROLLMENTS: degree, field_of_study, achievements
    users += User.in_soapbox_directory.profile_nonculinary_enrollments_degree_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_nonculinary_enrollments_field_of_study_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_nonculinary_enrollments_achievements_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->COMPETITION: name
    users += User.in_soapbox_directory.profile_competitions_name_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->INTERNSHIPS: establishment, supervisor, comments
    users += User.in_soapbox_directory.profile_internships_establishment_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_internships_supervisor_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_internships_comments_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->STAGES: establishment, expert, comments
    users += User.in_soapbox_directory.profile_stages_establishment_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_stages_expert_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_stages_comments_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    # USER->PROFILE->APPRENTICESHIPS: establishment, supervisor, comments
    users += User.in_soapbox_directory.profile_apprenticeships_establishment_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_apprenticeships_supervisor_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])
    users += User.in_soapbox_directory.profile_apprenticeships_comments_like(keyword).
      all(:conditions => ["users.id NOT in (?)", [0] + users.map(&:id)])

    users
  end

  # conditions hash for mediafeed visible users only
  # Ex. Employment.all(User.mediafeed_only_condition)
  def self.mediafeed_only_condition
    options = { 
      :joins => [:restaurant, :employee],
      :conditions =>  [
        'users.mediafeed_visible = ? AND
        users.visible = ? AND 
        users.role != ? OR
        (users.role != ? OR users.role IS NULL)', 
        true, true, 'admin', 'media'
      ],
      :order => "LOWER(last_name) ASC" 
    }
  end
end
