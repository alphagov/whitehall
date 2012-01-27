class MoveContactDetailsFromOrganisationToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :address, :text
    add_column :contacts, :postcode, :string
    add_column :contacts, :latitude, :decimal, precision: 15, scale: 10
    add_column :contacts, :longitude, :decimal, precision: 15, scale: 10
    add_column :contacts, :email, :string

    Organisation.all.each do |o|
      o.contacts.create(address: o.address, postcode: o.postcode,
                        latitude: o.latitude, longitude: o.longitude,
                        email: o.email, description: "Office address")
    end

    remove_column :organisations, :address
    remove_column :organisations, :postcode
    remove_column :organisations, :latitude
    remove_column :organisations, :longitude
    remove_column :organisations, :email
  end

  def down
    raise "Data will be lost if you migrate down; you'll need to manually do this."
    # add_column :contacts, :address, :text
    # add_column :contacts, :postcode, :string
    # add_column :contacts, :latitude, :decimal, precision: 15, scale: 10
    # add_column :contacts, :longitude, :decimal, precision: 15, scale: 10
    # add_column :contacts, :email, :string
    # remove_column :contacts, :address
    # remove_column :contacts, :postcode
    # remove_column :contacts, :latitude
    # remove_column :contacts, :longitude
    # remove_column :contacts, :email
  end
end