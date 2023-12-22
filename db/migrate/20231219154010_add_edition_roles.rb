class AddEditionRoles < ActiveRecord::Migration[7.0]
  def change
    create_join_table :edition, :roles, &:timestamps
  end
end
