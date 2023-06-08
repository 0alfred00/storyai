class FavoritesController < ApplicationController
  def index
    # shows favorites of current user
    @stories = current_user.favorites.map { |favorite| favorite.story }
  end
end
