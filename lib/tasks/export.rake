require "csv"
require "fileutils"

namespace :export do
  def routes_helper
    @routes_helper ||= Whitehall.url_maker
  end

  desc "Export mappings (for eg the Transition app to consume)"
  task :mappings => :environment do
    # Read off the MySQL slave - we want performance here and
    # non-contention as this job runs for up to 45 minutes.
    if Rails.env.production?
      mysql_slave_config = ActiveRecord::Base.configurations['production_slave']
      ActiveRecord::Base.establish_connection(mysql_slave_config)
    end

    exporter = Whitehall::Exporters::Mappings.new

    filename = 'public/government/mappings.csv'
    temporary_filename = filename + '.new'
    CSV.open(Rails.root.join(temporary_filename), 'wb') do |csv_out|
      exporter.export(csv_out)
    end

    FileUtils.mv(temporary_filename, filename)
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
            document.published? ? routes_helper.public_document_url(edition) : nil,
            edition.id,
            edition.title,
            edition.state,
            routes_helper.admin_edition_url(edition),
            *edition.authors.uniq.map(&:name)
          ]
        end
      end
    end
  end

  desc "Export list of published editions for orgs export:published_editions ORGS=org-slug"
  task :published_editions, [:orgs] => :environment do |_t, _args|
    orgs = if ENV['ORGS']
             Organisation.where(slug: ENV['ORGS'].split(',')).all
           else
             Organisation.all
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
        "Document collections",
        "Policies",
        "Topics",
        "Topical events"
      ]

      orgs.each do |org|
        org.published_editions.each do |edition|
          csv << [
            org.display_name,
            routes_helper.public_document_url(edition),
            routes_helper.admin_edition_url(edition),
            edition.title,
            edition.display_type,
            edition.public_timestamp,
            edition.respond_to?(:role_appointments) ? edition.role_appointments.map(&:slug).join('|') : nil,
            edition.respond_to?(:published_document_collections) ? edition.published_document_collections.map(&:slug).join('|') : nil,
            edition.respond_to?(:related_policies) ? edition.related_policies.map(&:slug).join('|') : nil,
            edition.respond_to?(:topics) ? edition.topics.map(&:slug).join('|') : nil,
            edition.respond_to?(:topical_events) ? edition.topical_events.map(&:slug).join('|') : nil,
          ]
        end
      end
    end
  end

  desc "Exports mappings between organisations and analytics keys"
  task :organisation_analytics => :environment do
    puts 'Mappings orgs to analytics keys...'
    path = 'tmp/organisation-analytics.csv'
    puts "Generating CSV in #{path}"

    CSV.open(path, 'w') do |csv|
      csv << [
        'Name',
        'Acronym',
        'Slug',
        'Analytics key'
      ]

      Organisation.all.each do |org|
        csv << [
          org.name,
          org.acronym,
          org.slug,
          org.analytics_identifier
        ]
      end
    end
  end

  desc "Exports HTML attachments for a particular publication as JSON"
  task :html_attachments, [:slug] => :environment do |_t, args|
    edition = Document.find_by(slug: args[:slug]).published_edition

    result = edition.html_attachments.map do |a|
      {
        title: a.title,
        body: a.govspeak_content_body,
        issued_date: a.created_at.strftime("%Y-%m-%d"),
        summary: edition.summary,
        slug: a.slug
      }
    end
    puts result.to_json
  end
end
