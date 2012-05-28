require "csv"

namespace :export do

  desc "Export list of documents (CREATED_SINCE timestamp optional)"
  task :document_list => :environment do
    include Rails.application.routes.url_helpers
    include Admin::EditionRoutesHelper

    created_since_text = ENV['CREATED_SINCE']
    created_since = created_since_text.present? ? Time.zone.parse(created_since_text) : Time.at(0)
    document_identities = DocIdentity.includes(:latest_edition).where('document_identities.created_at >= :created_since', created_since: created_since)
    documents = document_identities.map(&:latest_edition).compact

    CSV do |csv|
      csv << ["Title", "Admin URL", "State", "Type", "Authors"]
      documents.each do |document|
        author_names = document.edition_authors.map(&:user).uniq.map(&:name)
        admin_url = "https://whitehall.production.alphagov.co.uk" + admin_document_path(document)
        csv << [document.title, admin_url, document.state, document.type, *author_names]
      end
    end
  end

end
