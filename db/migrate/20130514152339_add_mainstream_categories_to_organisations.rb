class AddMainstreamCategoriesToOrganisations < ActiveRecord::Migration
  def change
    create_table :organisation_mainstream_categories do |t|
      t.references :organisation, null: false
      t.references :mainstream_category, null: false
      t.integer :ordering, null: false, default: 99
      t.timestamps
    end
    # the last 2 have names that are too long by default, so we'll just
    # explicitly name them all for consistency
    add_index :organisation_mainstream_categories, [:organisation_id], name: 'index_org_mainstream_cats_on_org_id'
    add_index :organisation_mainstream_categories, [:mainstream_category_id], name: 'index_org_mainstream_cats_on_mainstream_cat_id'
    add_index :organisation_mainstream_categories, [:organisation_id, :mainstream_category_id], unique: true, name: 'index_org_mainstream_cats_on_org_id_and_mainstream_cat_id'
  end
end
