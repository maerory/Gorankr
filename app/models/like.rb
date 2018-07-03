class Like < ActiveRecord::Base
    belongs_to :posts
    belongs_to :users
    
end
