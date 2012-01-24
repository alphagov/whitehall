class AddEmbassyContactDetailsToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :embassy_address, :text
    add_column :countries, :embassy_telephone, :string
    add_column :countries, :embassy_email, :string
  end
end