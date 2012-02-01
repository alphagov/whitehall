class AddNumbersToContacts < ActiveRecord::Migration
  def change
    create_table :contact_numbers, force: true do |t|
      t.references :contact
      t.string :label
      t.string :number
      t.timestamps
    end
  end
end