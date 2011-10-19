class AddContactDetailsToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :email, :string
    add_column :organisations, :address, :text
    add_column :organisations, :postcode, :string
    add_column :organisations, :latitude, :decimal, precision: 15, scale: 10
    add_column :organisations, :longitude, :decimal, precision: 15, scale: 10

    create_table :phone_numbers, force: true do |t|
      t.references :organisation
      t.string :number
      t.string :description
    end
  end
end