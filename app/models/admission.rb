class Admission < ApplicationRecord
    
    validates_uniqueness_of :user_id, :scope => 'chat_room_id'
    
    belongs_to :chat_room, counter_cache: true
    belongs_to :user
    
    after_commit :user_joined_chat_room_notification, on: :create
    after_commit :user_exited_chat_room_notification, on: :destroy
    
    def user_joined_chat_room_notification
        Pusher.trigger('chat_room', 'join', {chat_room_id: self.chat_room_id, user_name: self.user.user_name}.as_json)
    end
    
    def user_exited_chat_room_notification
        Pusher.trigger("chat_room_#{chat_room_id}", 'exit', self.as_json.merge({user_name: self.user.user_name}))
        Pusher.trigger("chat_room", 'exit', self.as_json)
    end
    
end
