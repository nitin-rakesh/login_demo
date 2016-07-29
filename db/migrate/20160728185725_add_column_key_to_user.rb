class AddColumnKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :key, :string
    add_column :users, :authentication_token, :string
  end
end
