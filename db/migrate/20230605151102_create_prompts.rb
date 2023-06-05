class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string :language
      t.integer :length
      t.string :user_input
      t.string :age_group
      t.string :genre
      t.integer :reference_story_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
