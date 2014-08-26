class AddShortUrlsToOrganisations < ActiveRecord::Migration
  def up
    add_column :organisations, :short_urls, :text

    Organisation.reset_column_information

    puts "Updating organisation short_urls from data pulled from the router-data repository"

    short_urls_grouped_by_org_slug = {}
    CSV.foreach(File.join(Rails.root, "db/migrate/20140826115841_add_short_urls_to_organisations_data/organisation_furls_csv_from_router_data.csv"), headers: true) do |row|
      org_slug = row[1].match(/[^\/]*$/).to_s
      short_urls_grouped_by_org_slug[org_slug] ||= []
      short_urls_grouped_by_org_slug[org_slug].push(row[0])
    end

    short_urls_grouped_by_org_slug.each do |org_slug, short_urls|
      if org = Organisation.find_by_slug(org_slug)
        org.update_attribute :short_urls, short_urls
      else
        puts "Organisation #{org_slug} not found with short urls #{short_urls}"
      end
    end
  end

  def down
    remove_column :organisations, :short_urls
  end
end
