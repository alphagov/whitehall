class AddChiefOfTheDefenceStaffFlagToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :chief_of_the_defence_staff, :boolean
  end
end