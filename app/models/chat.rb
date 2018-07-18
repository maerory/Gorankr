class Chat < ApplicationRecord
    belongs_to :user
    belongs_to :chat_room
    
    after_commit :chat_message_notification, on: :create
    
    def chat_message_notification
        Pusher.trigger("chat_room_#{self.chat_room_id}", "chat", self.as_json.merge({user_name: self.user.user_name}))
    end
end
