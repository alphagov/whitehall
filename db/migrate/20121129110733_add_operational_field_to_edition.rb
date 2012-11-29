class AddOperationalFieldToEdition < ActiveRecord::Migration
  def up
    add_column :editions, :operational_field_id, :integer
    add_index :editions, :operational_field_id
  end

  def down
    remove_index :editions, :operational_field_id
    remove_column :editions, :operational_field_id
  end
end
