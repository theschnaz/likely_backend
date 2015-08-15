class AddQuestionToSnaps < ActiveRecord::Migration
  def change
    add_column :snaps, :question, :string
  end
end
