class AddSeniorityToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :seniority, :integer, default: 100
  end
end
