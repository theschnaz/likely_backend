class AddSnappedByToSnaps < ActiveRecord::Migration
  def change
    add_column :snaps, :snapped_by, :integer
  end
end
