class CreateSnaps < ActiveRecord::Migration
  def change
    create_table :snaps do |t|
      t.timestamps
    end
  end
end
