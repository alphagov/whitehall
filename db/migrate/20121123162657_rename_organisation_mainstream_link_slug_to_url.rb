class RenameOrganisationMainstreamLinkSlugToUrl < ActiveRecord::Migration
  def change
    rename_column :organisation_mainstream_links, :slug, :url
  end
end
