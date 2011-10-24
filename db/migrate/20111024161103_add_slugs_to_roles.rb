class AddSlugsToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :slug, :string
    add_index :roles, :slug
  end
end
