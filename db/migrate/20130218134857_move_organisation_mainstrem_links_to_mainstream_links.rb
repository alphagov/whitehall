class MoveOrganisationMainstremLinksToMainstreamLinks < ActiveRecord::Migration
  def up
    rename_table :organisation_mainstream_links, :mainstream_links

    create_table :organisation_mainstream_links do |t|
      t.references :organisation
      t.references :mainstream_link
    end

    execute "INSERT INTO organisation_mainstream_links (mainstream_link_id, organisation_id) SELECT id, organisation_id FROM mainstream_links"

    remove_column :mainstream_links, :organisation_id
  end

  def down
    add_column :mainstream_links, :organisation_id, :integer

    execute %{
      UPDATE mainstream_links
      JOIN organisation_mainstream_links
      ON mainstream_links.id = organisation_mainstream_links.mainstream_link_id
      SET mainstream_links.organisation_id = organisation_mainstream_links.organisation_id
    }

    drop_table :organisation_mainstream_links
    rename_table :mainstream_links, :organisation_mainstream_links
  end
end
