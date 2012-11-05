class AddContactFormUrlToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :contact_form_url, :string
  end
end
