class AddImageToPeople < ActiveRecord::Migration
  def change
    add_column :people, :carrierwave_image, :string
  end
end
