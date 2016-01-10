class AddTopToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :top_id, :integer
    add_column :votes, :bottom_id, :integer
    add_column :votes, :top_vote, :integer
    add_column :votes, :bottom_id, :integer
  end
end
