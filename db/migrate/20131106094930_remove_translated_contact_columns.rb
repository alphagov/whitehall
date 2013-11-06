class RemoveTranslatedContactColumns < ActiveRecord::Migration
  def up
    remove_column :contacts, :title
    remove_column :contacts, :comments
    remove_column :contacts, :recipient
    remove_column :contacts, :street_address
    remove_column :contacts, :locality
    remove_column :contacts, :region
    remove_column :contacts, :email
    remove_column :contacts, :contact_form_url
  end
end
