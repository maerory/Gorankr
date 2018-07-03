class Post < ActiveRecord::Base
    has_many :comment
    belongs_to :user
    belongs_to :category
    has_many :users, through: :likes
    
end
