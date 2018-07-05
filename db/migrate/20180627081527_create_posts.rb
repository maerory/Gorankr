class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :content
      t.string :user_name
      t.string :game_name

      t.timestamps null: false
    end
  end
end
