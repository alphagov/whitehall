module DataHygiene
  class BulkOrganisationUpdater
    attr_accessor :errors

    def initialize(raw_csv)
      @parsed_csv = CSV.parse(raw_csv, headers: true)
      @errors = []
    end

    def call
      @parsed_csv.each do |row|
        process_row(row)
      end
    end

    def self.call(*args)
      new(*args).call
    end

    def validate
      expected_headers_sorted = ["Document type", "New lead organisations", "New supporting organisations", "Slug"]
      @validated_rows = @parsed_csv.each_with_index.map do |row, index|
        if index.zero? && row.headers.compact.sort != expected_headers_sorted
          errors << "Expected the following headers: #{expected_headers_sorted.join(',')}. Detected: #{row.headers.join(',')}"
          break
        end

        if row.fields.count != 4
          errors << "Exactly four fields expected. Detected: #{row.fields.count} (#{row.fields})"
          break
        end

        validate_row(row)
      end
    end

    def summarise_changes
      @validated_rows.map do |hash|
        {
          slug: hash[:document].slug,
          lead_orgs_summary: diff_orgs(
            hash[:document].latest_edition.lead_organisations.map(&:slug),
            hash[:lead_orgs].map(&:slug),
          ),
          supporting_orgs_summary: diff_orgs(
            hash[:document].latest_edition.supporting_organisations.map(&:slug),
            hash[:supporting_orgs].map(&:slug),
          ),
        }
      end
    end

    def diff_orgs(old_orgs, new_orgs)
      orgs_added = new_orgs - old_orgs
      orgs_removed = old_orgs - new_orgs

      status = []
      if old_orgs == new_orgs
        status << "Unchanged"
      elsif old_orgs.sort == new_orgs.sort
        status << "Reordered (from #{old_orgs.join(', ')})"
      else
        if orgs_added.count.positive?
          status << "Added #{orgs_added.join(', ')}"
        end
        if orgs_removed.count.positive?
          status << "Removed #{orgs_removed.join(', ')}"
        end
      end
      status.join(", ") + ". Result: #{new_orgs.join(', ')}"
    end

  private

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

    def validate_row(row)
      document = find_document(row)
      lead_orgs = find_new_lead_organisations(row)
      supporting_orgs = find_new_supporting_organisations(row)
      { document:, lead_orgs:, supporting_orgs: }
    end

    def find_document(row)
      slug = row.fetch("Slug")&.strip&.split("/")&.last
      document_type = row.fetch("Document type")&.strip&.delete(" ")

      return if slug.blank?

      documents = Document.where(slug:)
      documents = Document.where(slug:, document_type:) if documents.many? && document_type.present?
      statistics_announcements = StatisticsAnnouncement.where(slug:)

      if documents.many?
        errors << "error: ambiguous slug: #{slug} (document_types: #{documents.map(&:document_type)})"
        puts "error: ambiguous slug: #{slug} (document_types: #{documents.map(&:document_type)})"
      elsif documents.any?
        documents.first
      elsif statistics_announcements.any?
        statistics_announcements.first
      else
        errors << "Document not found: #{slug}"
        puts "error: #{slug}: could not find document"
      end
    end

    def find_organisations(row, column)
      column_data = row.fetch(column)
      return [] unless column_data

      column_data.split(",").map do |slug|
        Organisation.find_by!(slug: slug.strip.split("/").last)
      rescue ActiveRecord::RecordNotFound
        errors << "Organisation not found: #{slug.strip}"
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

      pre_publication_edition_updated =
        pre_publication_edition &&
        update_edition(
          pre_publication_edition,
          new_lead_organisations,
          new_supporting_organisations,
        )

      published_edition_updated =
        published_edition &&
        update_edition(
          published_edition,
          new_lead_organisations,
          new_supporting_organisations,
        )

      if pre_publication_edition_updated || published_edition_updated
        puts "#{document.slug}: UPDATED"
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
        puts "#{document.slug}: UPDATED"
      end
    end
  end
end
