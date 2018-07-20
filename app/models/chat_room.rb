class ChatRoom < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    has_many :chats
    
    validates_uniqueness_of :title

    after_commit :create_chat_room_notification, on: :create
    after_commit :edit_chat_room_notification, on: :update
    after_commit :delete_chat_room_notification, on: :destroy
    
    def room_empty?
        self.admissions.length == 0
    end
    
    def create_chat_room_notification
        Pusher.trigger("chat_room", 'create', self.as_json)
    end
    
    def edit_chat_room_notification
        Pusher.trigger("chat_room", 'update', self.as_json)
    end
    
    def delete_chat_room_notification
        Pusher.trigger("chat_room", 'delete', self.as_json)
    end

    def user_admit_room(user)
        Admission.create(user_id: user.id, chat_room_id: self.id)
    end
    
    def user_exit_room(user)
        Admission.where(user_id: user.id, chat_room_id: self.id)[0].destroy
    end
    
end
