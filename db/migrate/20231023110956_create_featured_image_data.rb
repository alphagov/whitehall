class CreateFeaturedImageData < ActiveRecord::Migration[7.0]
  def change
    create_table :featured_image_data do |t|
      t.string :carrierwave_image
      t.timestamps
    end
  end
end
