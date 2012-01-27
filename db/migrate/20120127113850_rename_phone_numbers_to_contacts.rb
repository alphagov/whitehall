class RenamePhoneNumbersToContacts < ActiveRecord::Migration
  def change
    rename_table :phone_numbers, :contacts
  end
end