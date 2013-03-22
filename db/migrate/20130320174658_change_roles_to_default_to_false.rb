class ChangeRolesToDefaultToFalse < ActiveRecord::Migration
  def change
    change_column :roles, :chief_of_the_defence_staff, :boolean, default: false, null: false
  end
end