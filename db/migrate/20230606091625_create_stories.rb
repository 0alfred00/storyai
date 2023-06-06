class CreateStories < ActiveRecord::Migration[7.0]
  def change
    create_table :stories do |t|
      t.string :title
      t.text :body
      t.text :summary
      t.boolean :public, default: false
      t.text :follow_up_summary
      # t.references :prompt, null: false, foreign_key: true

      t.timestamps
    end
    # add_index :stories, [:id, :reference_story_id], unique: true
  end
end
