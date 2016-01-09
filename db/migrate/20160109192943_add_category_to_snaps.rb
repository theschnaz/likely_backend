class AddCategoryToSnaps < ActiveRecord::Migration
  def change
    add_column :snaps, :category, :string
  end
end
