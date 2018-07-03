class CreateRecommends < ActiveRecord::Migration
  def change
    create_table :recommends do |t|

      t.timestamps null: false
    end
  end
end
