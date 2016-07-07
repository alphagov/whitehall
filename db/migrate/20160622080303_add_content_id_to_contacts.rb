class AddContentIdToContacts < ActiveRecord::Migration
  def up
    add_column :contacts, :content_id, :string
    Contact.find_each do |contact|
      contact.update_columns(content_id: SecureRandom.uuid)
    end
    change_column_null :contacts, :content_id, false
  end

  def down
    remove_column :contacts, :content_id
  end
end
