class AddContentIdToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :content_id, :string
  end
end
