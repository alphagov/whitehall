class AddFeaturedImageDataRefToTopicalEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :topical_events, :featured_image_data, index: true
  end
end
