class OpenaiController < ApplicationController
  def index
  end

  def create
    # prompt = "You are a world class author for children's books. Help me create a bedtime story to read to my child that is based on the hero's journey. It should be about a one-eyed crocodile tht is looking for water on Mars."
    @user_input = params[:prompt]
    @response_text = OpenaiService.new(@user_input).call
    render :index
  end
end
