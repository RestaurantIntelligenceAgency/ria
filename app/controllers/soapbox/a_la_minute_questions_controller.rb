class Soapbox::ALaMinuteQuestionsController < ApplicationController

  def index
    @questions = ALaMinuteQuestion.all(:include => "a_la_minute_answers",
                                       :order => "a_la_minute_answers.created_at DESC",
                                       :limit => 10)
  end

  def show
    @question = ALaMinuteQuestion.find(params[:id])
    @answers = ALaMinuteAnswer.newest_for(@question)
  end

end