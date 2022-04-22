class MoveFeaturedLinksToFeaturedLinkTranslations < ActiveRecord::Migration[6.1]
  def up
    existing_featured_links = ActiveRecord::Base.connection.execute("SELECT id, title, url FROM featured_links").to_a

    existing_featured_links.each do |link|
      FeaturedLinkTranslation.create!(
        featured_link_id: link[0],
        title: link[1],
        url: link[2],
        locale: "en",
      )
    end

    change_table :featured_links do |t| # rubocop:disable Rails/BulkChangeTable
      t.remove :url, :title
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
