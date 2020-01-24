module DataHygiene
  class BulkOrganisationUpdater
    def initialize(filename)
      @filename = filename
    end

    def call
      CSV.foreach(filename, **CSV_OPTIONS) do |row|
        process_row(row)
      end
    end

    def self.call(*args)
      new(*args).call
    end

  private

    attr_reader :filename

    CSV_OPTIONS = {
      headers: true,
    }.freeze

    def process_row(row)
      document = find_document(row)
      new_lead_organisations = find_new_lead_organisations(row)
      new_supporting_organisations = find_new_supporting_organisations(row)

      update_document(document, new_lead_organisations, new_supporting_organisations)
    end

    def find_document(row)
      Document.find_by!(slug: row.fetch("Slug"))
    end

    def find_organisations(row, column)
      column_data = row.fetch(column)
      return [] unless column_data

      column_data
        .split(",")
        .map { |slug| Organisation.find_by!(slug: slug.strip) }
    end

    def find_new_lead_organisations(row)
      find_organisations(row, "New lead organisations")
    end

    def find_new_supporting_organisations(row)
      find_organisations(row, "New supporting organisations")
    end

    def update_document(document, new_lead_organisations, new_supporting_organisations)
      edition = document.latest_edition

      return if edition.lead_organisations == new_lead_organisations \
        && edition.supporting_organisations == new_supporting_organisations

      puts "#{document.slug}: #{new_lead_organisations.map(&:slug).join(', ')} (#{new_supporting_organisations.map(&:slug).join(', ')})"

      edition.update(
        lead_organisations: new_lead_organisations,
        supporting_organisations: new_supporting_organisations,
      )

      PublishingApiDocumentRepublishingWorker.perform_async(document.id)
    end
  end
end
