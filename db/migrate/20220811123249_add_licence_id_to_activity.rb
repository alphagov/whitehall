class AddLicenceIdToActivity < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :licence_id, :integer
  end
end
