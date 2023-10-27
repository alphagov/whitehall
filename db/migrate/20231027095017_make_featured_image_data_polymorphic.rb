class MakeFeaturedImageDataPolymorphic < ActiveRecord::Migration[7.0]
  def change
    remove_column "organisations", "featured_image_data_id", :bigint
    change_table :featured_image_data, bulk: true do |t|
      t.column "featured_imageable_type", :string
      t.column "featured_imageable_id", :integer
    end
  end
end
