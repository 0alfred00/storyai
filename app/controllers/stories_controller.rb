class StoriesController < ApplicationController

  skip_before_action :authenticate_user!, only: :index

  def index
    @stories = Story.all
  end
end
