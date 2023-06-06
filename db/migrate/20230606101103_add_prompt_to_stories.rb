class AddPromptToStories < ActiveRecord::Migration[7.0]
  def change
    add_reference :stories, :prompt, null: false, foreign_key: true
  end
end
