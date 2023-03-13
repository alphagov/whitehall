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

      return unless document

      new_lead_organisations = find_new_lead_organisations(row)
      new_supporting_organisations = find_new_supporting_organisations(row)

      if document.is_a?(StatisticsAnnouncement)
        update_statistics_announcement(document, new_lead_organisations + new_supporting_organisations)
      else
        update_document(document, new_lead_organisations, new_supporting_organisations)
      end
    end

    def find_document(row)
      slug = row.fetch("Slug")&.strip
      document_type = row.fetch("Document type")&.strip

      return if slug.blank?

      documents = Document.where(slug:)
      documents = Document.where(slug:, document_type:) if documents.many? && document_type.present?
      statistics_announcements = StatisticsAnnouncement.where(slug:)

      if documents.many?
        puts "error: ambiguous slug: #{slug} (document_types: #{documents.map(&:document_type)})"
      elsif documents.any?
        documents.first
      elsif statistics_announcements.any?
        statistics_announcements.first
      else
        puts "error: #{slug}: could not find document"
      end
    end

    def find_organisations(row, column)
      column_data = row.fetch(column)
      return [] unless column_data

      column_data.split(",").map do |slug|
        Organisation.find_by!(slug: slug.strip)
      rescue ActiveRecord::RecordNotFound
        puts "error: couldn't find organisation: #{slug.strip}"

        raise
      end
    end

    def find_new_lead_organisations(row)
      find_organisations(row, "New lead organisations")
    end

    def find_new_supporting_organisations(row)
      find_organisations(row, "New supporting organisations")
    end

    def update_document(document, new_lead_organisations, new_supporting_organisations)
      published_edition = document.editions.find_by(state: :published)
      latest_edition = document.latest_edition
      pre_publication_edition = latest_edition

      if published_edition && (published_edition.id == latest_edition&.id)
        # Draft edition
        pre_publication_edition = nil
      end

      pre_publication_edition_updated = (
        pre_publication_edition &&
        update_edition(
          pre_publication_edition,
          new_lead_organisations,
          new_supporting_organisations,
        )
      )

      published_edition_updated = (
        published_edition &&
        update_edition(
          published_edition,
          new_lead_organisations,
          new_supporting_organisations,
        )
      )

      if pre_publication_edition_updated || published_edition_updated
        puts "#{document.slug}: #{new_lead_organisations.map(&:slug).join(', ')} (#{new_supporting_organisations.map(&:slug).join(', ')})"
      else
        if published_edition || pre_publication_edition
          puts "#{document.slug}: no update required"
        else
          puts "#{document.slug}: no edition found to update"
        end
        return
      end

      if !published_edition_updated
        Whitehall::PublishingApi.save_draft(
          pre_publication_edition,
          "republish",
          bulk_publishing: true,
        )
      else
        PublishingApiDocumentRepublishingWorker.perform_async(
          document.id,
          true, # bulk publishing
        )
      end
    end

    def update_edition(edition, new_lead_organisations, new_supporting_organisations)
      return false if
        edition.lead_organisations == new_lead_organisations &&
          edition.supporting_organisations == new_supporting_organisations

      edition.update( # rubocop:disable Rails/SaveBang
        lead_organisations: new_lead_organisations,
        supporting_organisations: new_supporting_organisations,
      )

      true
    end

    def update_statistics_announcement(document, new_organisations)
      if document.organisations == new_organisations
        puts "#{document.slug}: no update required"
      else
        document.update(organisations: new_organisations) # rubocop:disable Rails/SaveBang
        puts "#{document.slug}: #{new_organisations.map(&:slug).join(', ')}"
      end
    end
  end
end
