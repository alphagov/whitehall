class CleanupAdditionalContactFields < ActiveRecord::Migration
  def up
    remove_column :contacts, :description
    remove_column :contacts, :address
    remove_column :contacts, :postcode
  end

  def down
    add_column :contacts, :description, :string
    add_column :contacts, :address, :text
    add_column :contacts, :postcode, :string
  end
end
