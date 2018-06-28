class CreateLolData < ActiveRecord::Migration
  def change
    create_table :lol_data do |t|
      t.string :user_id
      t.string :lol_id
      t.string :rank
      
      t.timestamps null: false
    end
  end
end
