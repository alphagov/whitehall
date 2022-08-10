class AddExternalLinkToLicences < ActiveRecord::Migration[7.0]
  def change
    add_column :licences, :external_link, :boolean
  end
end
