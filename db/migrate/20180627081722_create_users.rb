class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :password_digest
      t.integer :age
      t.string :discord
      t.string :lol_id
      t.string :ow_id
      t.string :pubg_id
      
      t.timestamps null: false
    end
  end
end
