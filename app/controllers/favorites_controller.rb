class FavoritesController < ApplicationController
  def index
    # shows favorites of current user
    @stories = current_user.favorites
  end
end

newfav = Favorite.create(user_id: 11, story_id: 1)
newfav.save
newfav = Favorite.create(user_id: 11, story_id: 2)
newfav.save
newfav = Favorite.create(user_id: 11, story_id: 3)
newfav.save
