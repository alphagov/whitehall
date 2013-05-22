require "csv"

namespace :export do

  PUBLIC_HOST = "www.gov.uk"
  ADMIN_HOST = "whitehall-admin.production.alphagov.co.uk"

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new(host: PUBLIC_HOST)
  end

  desc "Export list of documents"
  task :document_list => :environment do
    CSV do |csv|
      csv << [
        "Document ID",
        "Document slug",
        "Document type",
        "Document latest edition state",
        "Document public URL",
        "Edition ID",
        "Edition title",
        "Edition state",
        "Admin edition URL",
        "Authors..."
      ]
      Document.find_each do |document|
        document.editions.sort_by(&:id).each do |edition|
          csv << [
            document.id,
            document.slug,
            document.document_type,
            document.latest_edition.state,
            document.published? ? routes_helper.public_document_url(edition, host: PUBLIC_HOST, protocol: "https") : nil,
            edition.id,
            edition.title,
            edition.state,
            routes_helper.admin_edition_url(edition, host: ADMIN_HOST, protocol: "https"),
            *edition.authors.uniq.map(&:name)
          ]
        end
      end
    end
  end

  desc "Export list of published editions for orgs export:published_editions ORGS=org-slug"
  task :published_editions, [:orgs] => :environment do |t, args|

    if ENV['ORGS']
      orgs = Organisation.where(slug: ENV['ORGS'].split(',')).all
    else
      orgs = Organisation.all
    end
    puts "Processing #{orgs.map(&:display_name)}"
    path = "tmp/published_editions-#{Time.now.to_i}.csv"
    puts "generating csv in #{path}"

    CSV.open(path, "w") do |csv|

      csv << [
        "Org",
        "URL",
        "Admin URL",
        "Title"
      ]

      orgs.each do |org|
        org.published_editions.each do |edition|
          csv << [
            org.display_name,
            # edition.slug,
            routes_helper.public_document_url(edition, host: PUBLIC_HOST, protocol: "https"),
            routes_helper.admin_edition_url(edition, host: ADMIN_HOST, protocol: "https"),
            edition.title
          ]
        end
        org.mainstream_links.each do |link|
          csv << [
            org.display_name,
            # edition.slug,
            link.url,
            "",
            link.title
          ]
        end
      end
    end
  end

end
