class CreateOwData < ActiveRecord::Migration
  def change
    create_table :ow_data do |t|
      t.string :user_id
      t.string :ow_id
      t.integer :score
      
      t.timestamps null: false
    end
  end
end
