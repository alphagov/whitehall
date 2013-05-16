require "csv"

namespace :export do

  PUBLIC_HOST = "www.gov.uk"
  ADMIN_HOST = "whitehall-admin.production.alphagov.co.uk"

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

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new(host: PUBLIC_HOST)
  end

end
