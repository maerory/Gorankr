class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      
      t.string :user_name
      t.integer :age
      t.string :game_name
      t.text :game_data
      t.boolean :team_queue, default: false
      
      t.timestamps
    end
  end
end
