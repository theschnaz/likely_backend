class AddValuesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :username, :string
    add_column :users, :email, :string
    add_column :users, :facebook_key, :string
    add_column :users, :fb_pic_square, :string
    add_column :users, :fb_pic_large, :string
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :created_at, :datetime
    add_column :users, :updated_at, :datetime
  end
end
