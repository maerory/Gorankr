class User < ActiveRecord::Base
    has_secure_password
    validates :user_name, uniqueness: true
    has_many :comments
    has_many :posts
    has_many :users, through: :recommend
end
