class AddWorldwideOrgansationPages < ActiveRecord::Migration[7.1]
  def change
    create_table :worldwide_organisation_pages do |t|
      t.string :summary
      t.text :body

      t.integer :editionable_worldwide_organisation_id
      t.integer :corporate_information_page_type_id

      t.timestamps
    end
  end
end
