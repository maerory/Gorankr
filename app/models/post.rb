class Post < ActiveRecord::Base
    has_many :comments
    belongs_to :user
    has_many :likes
    belongs_to :category 
    has_many :users, through: :likes
    
end
