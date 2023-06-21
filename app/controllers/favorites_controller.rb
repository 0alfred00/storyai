class FavoritesController < ApplicationController
  def index
    # shows stories that current user has saved as favorite
    @stories = current_user.favorites.map { |favorite| favorite.story }
  end

  def create
    @favorite = Favorite.new
    @story = Story.find(params[:story_id])
    @favorite.user = current_user
    @favorite.story = @story
    @favorite.save
    # redirect_to request.referrer
  end

  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy
    # redirect_to request.referrer
  end
end
