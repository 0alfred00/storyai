class FavoritesController < ApplicationController
  def index
    # shows favorites of current user
    @stories = current_user.favorites.map { |favorite| favorite.story }
  end

  def create
    @favorite = Favorite.new
    @story = Story.find(params[:story_id])
    @favorite.user = current_user
    @favorite.story = @story
    @favorite.save
    # respond_to do |format|
    # render json: { partial: render_to_string(partial: "shared/favorite_icon", layout: false, formats: :html, locals: { favorite: @favorite, story: @favorite.story}) }, status: 422   # end
      # render partial: "shared/favorite_icon", status: :ok
    redirect_to request.referrer
  end

  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy
    redirect_to request.referrer
  end
end
