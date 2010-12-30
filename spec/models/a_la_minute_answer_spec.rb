# == Schema Information
#
# Table name: a_la_minute_answers
#
#  id                      :integer         not null, primary key
#  answer                  :text
#  a_la_minute_question_id :integer
#  responder_id            :integer
#  responder_type          :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  show_as_public          :boolean
#

require 'spec_helper'

describe ALaMinuteAnswer do
  before(:each) do
    @question = Factory(:a_la_minute_question)
    @responder = Factory(:restaurant)
    @valid_attributes = {
      :answer => "value for answer",
      :a_la_minute_question => @question,
      :responder => @restaurant,
      :show_as_public => false
    }
  end

  it "should create a new instance given valid attributes" do
    ALaMinuteAnswer.create!(@valid_attributes)
  end

  describe "#show_as_public" do
    it "should only find public answers" do
      public_answer = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true))
      private_answer = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => false))

      # show_as_public is created automagically by search logic, this test just reinforces this
      ALaMinuteAnswer.show_as_public.all.should == [public_answer]
    end
  end

  describe "#newest_for" do
    context "for responders" do
      it "should only find the most recent answer for each question" do
        old_answer = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :responder => @responder, :created_at => 4.hours.ago))
        new_answer = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :responder => @responder, :created_at => 2.hours.ago))

        ALaMinuteAnswer.newest_for(@responder).should == [new_answer]
      end
    end
    context "for questions" do
      it "should only find the most recent answers for each restaurant" do
        responder_1 = Factory(:restaurant)
        responder_2 = Factory(:restaurant)

        old_answer_1 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :responder => responder_1, :created_at => 4.hours.ago))
        new_answer_1 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :responder => responder_1, :created_at => 3.hours.ago))
        old_answer_2 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :responder => responder_2, :created_at => 2.hours.ago))
        new_answer_2 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :responder => responder_2, :created_at => 1.hours.ago))

        ALaMinuteAnswer.newest_for(@question).should == [new_answer_2, new_answer_1]
      end
    end
  end

  describe "#public_profile_for=" do
    it "should show all public answers for a given responder" do
      q1 = Factory(:a_la_minute_question)
      q2 = Factory(:a_la_minute_question)
      q3 = Factory(:a_la_minute_question)
      q4 = Factory(:a_la_minute_question)
      ans_1 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :a_la_minute_question => q1, :created_at => 1.week.ago))
      ans_2 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :a_la_minute_question => q2, :created_at => 1.day.ago))
      ans_3 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :a_la_minute_question => q3, :created_at => 3.days.ago))
      ans_4 = ALaMinuteAnswer.create!(@valid_attributes.merge(:show_as_public => true, :a_la_minute_question => q4, :created_at => 2.days.ago))
      @responder.a_la_minute_answers = [ans_1, ans_2, ans_3, ans_4]
      ALaMinuteAnswer.public_profile_for(@responder).should == [ans_2, ans_4, ans_3, ans_1]
    end
  end

  describe "#archived_for" do
    it "should return all archived answers for the question" do
      q1 = Factory(:a_la_minute_question)
      ans_1 = Factory(:a_la_minute_answer, :a_la_minute_question => q1, :created_at => 1.day.ago)
      ans_2 = Factory(:a_la_minute_answer, :a_la_minute_question => q1, :created_at => 3.day.ago)
      ans_3 = Factory(:a_la_minute_answer, :a_la_minute_question => q1, :created_at => 2.day.ago)
      ans_4 = Factory(:a_la_minute_answer, :a_la_minute_question => q1, :created_at => 1.hour.ago)
      ALaMinuteAnswer.archived_for(q1).should == [ans_1, ans_3, ans_2]
    end
  end
end
