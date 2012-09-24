class AddOtherMainstreamCategoriesForSpecialistGuidance < ActiveRecord::Migration
  def change
    create_table :edition_mainstream_categories do |t|
      t.references :edition
      t.references :mainstream_category

      t.timestamps
    end
  end
end
