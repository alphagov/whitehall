require "csv"

namespace :report do
  desc "Find all references to GSI/GSE/GCSX/GSX domains"
  task find_gsi_domain_references: :environment do
    CSV.open(Rails.root.join("tmp/gsi_domain_contact_items.csv"), "wb") do |csv|
      csv << ["Title", "URL", "Publishing application", "Publishing organisation", "Format", "Domain", "Content ID"]

      domains = %w[gsi gse gcsx gsx]

      domains.each do |domain|
        puts "Searching for #{domain}.gov.uk..."

        contacts = Contact.eager_load(:translations).where("contact_translations.email like ?", "%#{domain}.gov.uk%")
        number_of_contacts = 0

        contacts.each do |contact|
          next unless contact.contactable.try(:govuk_status) == "live"

          number_of_contacts += 1

          csv << [
            contact.title,
            "https://www.gov.uk/government/organisations/#{contact.contactable.slug}",
            "whitehall",
            contact.contactable.name,
            "contact",
            domain,
            contact.content_id,
          ]
        end

        puts "Found #{number_of_contacts} contacts containing #{domain}.gov.uk"
      end
    end

    puts "Finished searching"
    csv_path = Rails.root.join("tmp/gsi_domain_contact_items.csv")
    puts "CSV file at #{csv_path}"
  end
end
