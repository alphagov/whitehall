class AddContactTypeToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contact_type_id, :integer
    execute('UPDATE contacts SET contact_type_id = 1')
    change_column_null :contacts, :contact_type_id, false
    add_index :contacts, :contact_type_id
  end
end
