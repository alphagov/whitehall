class AddAlternativeFormatContactEmailToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :alternative_format_contact_email, :string
  end
end
