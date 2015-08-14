class AddLabelsToSnaps < ActiveRecord::Migration
  def change
    add_column :snaps, :left_text, :string
    add_column :snaps, :right_text, :string
  end
end
