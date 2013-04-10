class AddExtraFieldsToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :attends_cabinet_type_id, :integer
    add_column :roles, :role_payment_type_id, :integer
  end
end
