class AddFeaturedImageDataRefToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_reference :organisations, :featured_image_data, index: true
  end
end
