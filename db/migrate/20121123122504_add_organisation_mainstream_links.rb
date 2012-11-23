class AddOrganisationMainstreamLinks < ActiveRecord::Migration
  def change
    create_table :organisation_mainstream_links, force: true do |t|
      t.integer :organisation_id
      t.string :slug
      t.string :title
      t.timestamps
    end
  end
end
