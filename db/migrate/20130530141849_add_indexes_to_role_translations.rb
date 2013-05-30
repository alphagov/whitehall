class AddIndexesToRoleTranslations < ActiveRecord::Migration
  def change
    add_index :roles, :attends_cabinet_type_id
    add_index :role_translations, :name
  end
end
