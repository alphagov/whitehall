class AddDescriptionToLicences < ActiveRecord::Migration[7.0]
  def change
    add_column :licences, :description, :text
  end
end
