class MediaRequest < ActiveRecord::Base
  serialize :fields, Hash

  belongs_to :sender, :class_name => 'User'
  belongs_to :media_request_type
  has_many :media_request_conversations, :dependent => :destroy
  has_many :conversations_with_comments, :class_name => 'MediaRequestConversation', :conditions => 'comments_count > 0'

  # Recipients are Employment objects, not Employees directly
  has_many :recipients, :through => :media_request_conversations
  has_many :attachments, :as => :attachable, :class_name => '::Attachment'
  validates_presence_of :sender_id

  accepts_nested_attributes_for :attachments

  named_scope :past_due, lambda {{ :conditions => ['due_date < ?', Date.today] }}
  named_scope :for_dashboard, :order => "created_at DESC", :conditions => {:status => ["approved", "pending"]}

  before_save :assign_recipients_from_restaurants

  attr_accessor :restaurant_ids, :subject_matter_ids, :restaurant_role_ids

  include AASM

  aasm_column :status
  aasm_initial_state :draft
  aasm_state :draft
  aasm_state :pending
  aasm_state :approved
  aasm_state :closed

  aasm_event :approve, :success => :deliver_notifications do
    transitions :to => :approved, :from => [:pending]
  end

  aasm_event :fill_out do
    transitions :to => :pending, :from => [:pending, :draft]
  end

  def restaurants
    Restaurant.all(:conditions => {:id => recipients.map(&:restaurant_id).uniq})
  end

  def deliver_notifications
    for conversation in self.media_request_conversations
      UserMailer.deliver_media_request_notification(self, conversation)
    end
  end

  def conversation_with_recipient(employment)
    media_request_conversations.first(:conditions => {:recipient_id => employment.id})
  end

  def publication_string
    "A writer" + (self.publication.blank? ? "" : " from #{self.publication}")
  end

  def reply_count
    @reply_count ||= conversations_with_comments.size
  end

  def message_with_fields(before_key = '', after_key = ': ')
    message_with_fields = fields.inject("") do |result, (key,value)|
      result += "#{before_key + key.to_s.humanize + after_key + value}\n"
    end
    return message_with_fields if message.blank?
    message_with_fields += "\n#{message}"
  end

  def fields=(fields)
    fields.delete_if {|k,v| v.blank? } if fields.respond_to?(:delete_if)
    write_attribute(:fields, fields)
  end

  def fields
    read_attribute(:fields) || Hash.new
  end

  protected

  def assign_recipients_from_restaurants
    if @restaurant_ids
      if !@subject_matter_ids.blank?
        employments = Employment.all(:include => :responsibilities, :conditions => {:restaurant_id => @restaurant_ids, :responsibilities => {:subject_matter_id => @subject_matter_ids}})
        @subject_matter_ids = nil
      elsif !@restaurant_role_ids.blank?
        employments = Employment.all(:conditions => {:restaurant_id => @restaurant_ids, :restaurant_role_id => @restaurant_role_ids})
        @restaurant_role_ids = nil
      else
        employments = Employment.all(:conditions => {:restaurant_id => @restaurant_ids})
      end
      @restaurant_ids = nil
      self.recipients = employments
    end
  end

end
