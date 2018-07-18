class User < ActiveRecord::Base
    has_secure_password
    validates :user_name, uniqueness: true
    has_many :comments
    has_many :posts
    has_many :users, class_name: :User, through: :recommends
    
    has_many :chat_rooms, through: :admissions
    has_many :chats
    has_many :admissions
    
    def joined_room?(room)
        self.chat_rooms.include?(room)
    end
end
