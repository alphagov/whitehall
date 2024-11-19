require "csv"
require "fileutils"

namespace :export do
  desc "Export list of documents"
  task document_list: :environment do
    path = "tmp/document_list-#{Time.zone.now.to_i}.csv"
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
        "Authors...",
      ]
      Document.find_each do |document|
        document.editions.sort_by(&:id).each do |edition|
          csv << [
            document.id,
            document.slug,
            document.display_type,
            document.latest_edition.state,
            document.live? ? edition.public_url : nil,
            edition.id,
            edition.title,
            edition.state,
            admin_edition_url(edition),
            *edition.authors.uniq.map(&:name),
          ]
        end
      end
    end
  end

  desc "Exports mappings between organisations and analytics keys"
  task organisation_analytics: :environment do
    puts "Mappings orgs to analytics keys..."
    path = "tmp/organisation-analytics.csv"
    puts "Generating CSV in #{path}"

    CSV.open(path, "w") do |csv|
      csv << [
        "Name",
        "Acronym",
        "Slug",
        "Analytics key",
      ]

      Organisation.all.find_each do |org|
        csv << [
          org.name,
          org.acronym,
          org.slug,
          org.analytics_identifier,
        ]
      end
    end
  end

  desc "Exports HTML attachments for a particular publication as JSON"
  task :html_attachments, [:slug] => :environment do |_t, args|
    edition = Document.find_by(slug: args[:slug]).live_edition

    result = edition.html_attachments.map do |a|
      {
        title: a.title,
        body: a.body,
        issued_date: a.created_at.strftime("%Y-%m-%d"),
        summary: edition.summary,
        slug: a.slug,
      }
    end
    puts result.to_json
  end
end
