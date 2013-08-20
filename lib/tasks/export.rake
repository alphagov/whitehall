require "csv"

namespace :export do

  PUBLIC_HOST = "www.gov.uk"
  ADMIN_HOST = "whitehall-admin.production.alphagov.co.uk"

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new(host: PUBLIC_HOST)
  end

  desc "Export list of documents"
  task :document_list => :environment do
    path = "tmp/document_list-#{Time.now.to_i}.csv"
    puts "generating csv in #{path}"
    CSV.open(path, "w") do |csv|
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
            document.display_type,
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
        "Title",
        "Type",
        "public_timestamp",
        "People",
        "Document series",
        "Policies",
        "Topics",
        "Topical events"
      ]

      orgs.each do |org|
        org.published_editions.each do |edition|
          csv << [
            org.display_name,
            routes_helper.public_document_url(edition, host: PUBLIC_HOST, protocol: "https"),
            routes_helper.admin_edition_url(edition, host: ADMIN_HOST, protocol: "https"),
            edition.title,
            edition.display_type,
            edition.public_timestamp,
            edition.respond_to?(:role_appointments) ? edition.role_appointments.map(&:slug).join('|') : nil,
            edition.respond_to?(:document_series) ? edition.document_series.map(&:slug).join('|') : nil,
            edition.respond_to?(:related_policies) ? edition.related_policies.map(&:slug).join('|') : nil,
            edition.respond_to?(:topics) ? edition.topics.map(&:slug).join('|') : nil,
            edition.respond_to?(:topical_events) ? edition.topical_events.map(&:slug).join('|') : nil,
          ]
        end
      end
    end
  end

end
