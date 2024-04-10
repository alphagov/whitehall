class CreateWorldwideOrganisationPages < ActiveRecord::Migration[7.1]
  def change
    create_table :worldwide_organisation_pages do |t|
      t.integer "corporate_information_page_type_id", null: false
      t.integer "edition_id", null: false
      t.text "summary"
      t.text "body"

      t.timestamps

      t.index %w[edition_id], name: "index_worldwide_organisation_pages_on_edition_id"
    end
  end
end
