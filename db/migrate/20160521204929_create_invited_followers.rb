class CreateInvitedFollowers < ActiveRecord::Migration
  def change
    create_table :invited_followers do |t|
	  t.column :email, :string
	  t.column :snap, :integer
      t.timestamps
    end
  end
end
