class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.attachment :image
      t.text :post_description
      t.timestamps null: false
    end
  end
end
