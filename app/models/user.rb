class User < ActiveRecord::Base
    has_secure_password
    validates :user_name, uniqueness: true
    has_many :comments
    has_many :posts
end
