class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      
      t.string :user_name
      t.integer :age
      t.string :game_name
      t.text :game_data
      t.boolean :online
      t.string :game_type
      
      t.timestamps
    end
  end
end
