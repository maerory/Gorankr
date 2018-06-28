class CreatePubgData < ActiveRecord::Migration
  def change
    create_table :pubg_data do |t|
      t.integer :score
      t.string :user_id
      t.string :pubg_id
      
      t.timestamps null: false
    end
  end
end
