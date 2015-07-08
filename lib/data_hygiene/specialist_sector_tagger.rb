class SpecialistSectorTagger
  def self.process_from_csv(csv_location, logger: Logger.new(nil))
    CSV.foreach(csv_location, headers: true) do |row|
      new(
        row.fetch("document_type"),
        row.fetch("slug"),
        row.fetch("tag"),
        logger: logger,
      ).process
    end
  end

  def initialize(document_type,
                 document_slug,
                 specialist_sector_slug,
                 logger: Logger.new(nil)
                )
    @document_type = document_type
    @document_slug = document_slug
    @specialist_sector_slug = specialist_sector_slug
    @logger = logger
  end

  def process
    if document.nil?
      log "warning: failed to find #{@document_type} document with slug" +
        " #{@document_slug} - skipping"
      return
    end

    document.editions.each do |edition|
      if edition.specialist_sectors.any? {|s| s.tag == @specialist_sector_slug }
        log "skipping '#{document.slug}' #{document.document_type} edition" +
          " #{edition.id}(#{edition.state})" +
          "- already tagged to #{@specialist_sector_slug}"
      else
        log "tagging '#{document.slug}' #{document.document_type} edition" +
          " #{edition.id}(#{edition.state})" +
          " to #{@specialist_sector_slug}"
        SpecialistSector.create!(edition: edition, tag: @specialist_sector_slug)
      end
    end
    if document.published_edition.present?
      register_edition(document.published_edition)
    end
  end

private

  def document
    @document ||= Document.at_slug(@document_type, @document_slug)
  end

  def register_edition(edition)
    log "registering '#{edition.slug}' #{document.document_type}"
    edition.reload
    register_with_panopticon(edition)
    register_with_publishing_api(edition)
    register_with_search(edition)
  end

  def register_with_panopticon(edition)
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  def register_with_publishing_api(edition)
    Whitehall::PublishingApi.republish_async(edition)
  end

  def register_with_search(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  def log(message)
    @logger.info message
  end
end
