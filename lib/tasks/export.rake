require "csv"
require "fileutils"

namespace :export do
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
