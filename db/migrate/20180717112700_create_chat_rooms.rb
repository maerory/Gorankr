class CreateChatRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_rooms do |t|
      t.string :title, unique: true
      t.integer :admissions_count, default: 0
      t.timestamps
    end
  end
end
