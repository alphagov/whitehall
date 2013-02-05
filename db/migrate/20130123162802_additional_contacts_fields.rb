class AdditionalContactsFields < ActiveRecord::Migration
  def up
    # Add, rather than rename fields to avoid errors during migration
    # where two versions of the code will be running. This relies on a
    # future cleanup by running CleanupAdditionalContactFields
    add_column :contacts, :title, :string
    add_column :contacts, :comments, :text
    add_column :contacts, :recipient, :string
    add_column :contacts, :street_address, :text
    add_column :contacts, :locality, :string
    add_column :contacts, :region, :string
    add_column :contacts, :postal_code, :string
    add_column :contacts, :country_id, :integer

    execute "update contacts set
      title=description,
      street_address=address,
      postal_code=postcode,
      country_id=(select id from world_locations where name='United Kingdom')"
  end

  def down
    remove_column :contacts, :title
    remove_column :contacts, :comments
    remove_column :contacts, :recipient
    remove_column :contacts, :street_address
    remove_column :contacts, :locality
    remove_column :contacts, :region
    remove_column :contacts, :postal_code
    remove_column :contacts, :country_id
  end
end
