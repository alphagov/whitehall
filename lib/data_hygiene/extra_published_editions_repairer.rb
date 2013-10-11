module DataHygiene
  class ExtraPublishedEditionsRepairer
    def initialize(logger = nil)
      @logger = logger || Logger.new($stderr)
    end

    def documents
      @documents ||= Document.
        joins("
INNER JOIN (
  #{Edition.
      unscoped.
      select('document_id, count(editions.id) as pub_count').
      published.
      group('document_id').to_sql
  }) as pub_count ON pub_count.document_id = documents.id").
        select('documents.*, pub_count.pub_count').
        where('pub_count.pub_count > 1')
    end

    def how_many
      documents.count
    end

    def most_recent_published_edition_for_document(document)
      document.editions.published.order(:id).last
    end

    def repair!
      @logger.info "#{how_many} documents with > 1 published edition. ARCHIVING Begins"
      documents.each.with_index do |document, idx|
        @logger.info "#{idx +1}. '#{document.slug}' Archiving #{document.editions.published.count - 1} extra published editions"
        begin
          most_recent_published_edition_for_document(document).archive_previous_editions!
        rescue => e
          @logger.error "PROBLEM: #{e.message}"
        end
      end
      @logger.info "ARCHIVING Ends"
    end
  end
end