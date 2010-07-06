# == Schema Information
# Schema version: 20100426230131
#
# Table name: media_requests
#
#  id                    :integer         not null, primary key
#  sender_id             :integer
#  message               :text
#  created_at            :datetime
#  updated_at            :datetime
#  due_date              :date
#  media_request_type_id :integer
#  fields                :text
#  status                :string(255)
#  publication           :string(255)
#  admin                 :boolean
#

require 'spec/spec_helper'

describe MediaRequest do
  should_belong_to :sender, :class_name => 'User'
  should_validate_presence_of :sender_id

  should_belong_to :media_request_type
  should_belong_to :employment_search
  should_have_many :media_request_discussions
  should_have_many :restaurants, :through => :media_request_discussions

  should_have_many :attachments, :as => :attachable, :class_name => '::Attachment', :dependent => :destroy

  before(:each) do
    @employee = Factory(:user, :username => "employee", :email => "employee@example.com")
    @restaurant = Factory(:restaurant)
    @employment = Factory(:employment, :restaurant => @restaurant, :employee => @employee)
  end

  describe "senders and receivers" do
    it "should build conversations with other folks" do
      mr = Factory(:media_request, :sender => Factory(:user), :restaurants => [@restaurant])
      mr.media_request_discussions.first.restaurant.should == @restaurant
      @restaurant.media_request_discussions.first.media_request.should == mr
    end

    describe "finding" do
      before do
        @media_request = Factory(:media_request,
                                  :sender => Factory(:user),
                                  :restaurants => [@restaurant])
      end

      it "conversation by way of restaurant should include the first conversation" do
        @media_request.discussion_with_restaurant(@restaurant).should be_a(MediaRequestDiscussion)
      end

      it "restaurants" do
        @media_request.restaurants.should == [@restaurant]
      end
    end
  end

  describe "fields" do
    before(:each) do
      @request = Factory.build(:media_request)
      @request.stubs(:restaurant_ids).returns([1])
    end

    it "should be empty Hash for new instance" do
      @request.fields.should == {}
    end

    it "should be a hash with keys and values" do
      @request.fields = {:hello => "No!"}
      @request.fields.should be_a(Hash)
      @request.save
      MediaRequest.find(@request.id).fields.should be_a(Hash)
    end

    it "should reject blank values" do
      @request.fields = {:hello => '', :nothing => "Booya!"}
      @request.fields[:hello].should be_nil
    end
  end

  describe "message_with_fields" do
    before(:each) do
      @request = Factory.build(:media_request)
    end

    it "should join a field and the message" do
      @request.message = "This is a message"
      @request.fields = {:date => "December 10"}
      @request.message_with_fields.should == <<-EOT.gsub(/^[ ]+/,'').chomp
      Date: December 10

      This is a message
      EOT
    end

    it "should join all fields and the message" do
      @request.message = "Messages are neat"
      @request.fields = {:photo_requirements => "8x10 large", :time_of_event => "10am"}
      @request.message_with_fields.should include("Photo requirements: 8x10 large")
      @request.message_with_fields.should include("Time of event: 10am")
      @request.message_with_fields.should include("Messages are neat")
    end
  end

  describe "status" do
    before(:each) do
      @request = Factory.build(:media_request)
    end

    it "should start out as a draft" do
      @request.should be_draft
    end

    it "should transition to pending after fields are filled in" do
      @request.fill_out!
      @request.should be_pending
    end

    it "should be approvable" do
      UserMailer.stubs(:deliver_media_request_notification).returns(true)
      media_request = Factory(:pending_media_request)
      media_request.approve
      media_request.save
      media_request.should_not be_pending
      media_request.should be_approved
    end

    describe "when approved email" do
      xit "should be sent to each restaurant" do
        @request = Factory.build(:media_request, :status => 'pending')
        @receiver = Factory(:user, :name => "Hambone Fisher", :email => "hammy@spammy.com")
        @request.sender = Factory(:media_user, :username => "jim", :email => "media@media.com")
        @request.restaurants = [@restaurant]
        UserMailer.expects(:deliver_media_request_notification)
        @request.approve!.should == true
        Delayed::Job.last.invoke_job if defined?(Delayed::Job)
      end
    end
  end

  describe "brand new request" do
    before do
      @subject_matter = Factory(:subject_matter, :name => "Ham")
      @employment2 = Factory(:assigned_employment, :subject_matters => [@subject_matter], :restaurant => @restaurant)
      sender = Factory(:media_user)
      @request = Factory.build(:media_request, :sender => sender, :restaurants => [])
    end

    it "should be invalid when no restaurants are found" do
      @request.restaurant_ids = []
      @request.should_not be_valid
      @request.save.should be_false
    end

    it "should be valid with restaurants" do
      @request.restaurant_ids = [@restaurant.id]
      @request.should be_valid
    end
  end

end
