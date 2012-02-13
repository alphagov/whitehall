class AddResponsibilitiesToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :responsibilities, :text
  end
end
