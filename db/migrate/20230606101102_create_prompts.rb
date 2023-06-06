class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string :language
      t.integer :length
      t.string :user_input
      t.string :age_group
      t.string :genre
      t.references :reference_story, foreign_key: { to_table: 'stories' }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # add_index :prompts, [:id, :user_id], unique: true
  end
end
