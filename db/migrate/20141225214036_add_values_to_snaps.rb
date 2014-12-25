class AddValuesToSnaps < ActiveRecord::Migration
  def change
      add_column :snaps, :vote_left, :integer
	  add_column :snaps, :vote_right, :integer
	  add_column :snaps, :skips, :integer
	  add_column :snaps, :photo_url, :string
	  add_column :users, :user_id, :string
  end
end
