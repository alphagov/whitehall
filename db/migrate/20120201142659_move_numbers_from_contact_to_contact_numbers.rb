class MoveNumbersFromContactToContactNumbers < ActiveRecord::Migration
  def change
    insert %{
      INSERT INTO contact_numbers (contact_id, label, number)
      SELECT id, description, number
      FROM contacts
      WHERE number is not null AND number != ''
    }

    remove_column :contacts, :number
  end
end
