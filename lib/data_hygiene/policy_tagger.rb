class PolicyTagger
  def self.process_from_csv(csv_location, logger: Logger.new(nil))
    CSV.foreach(csv_location, headers: true) do |row|
      new(
        slug:               row.fetch("slug"),
        policies_to_remove: sanitised_policies(row.fetch("policies_to_remove")),
        policies_to_add:    sanitised_policies(row.fetch("policies_to_add")),
        logger:             logger,
      ).process
    end
  end

  def initialize(slug:,
                 policies_to_remove:,
                 policies_to_add:,
                 logger: Logger.new(nil)
                )
    @slug = slug
    @policies_to_remove = policies_to_remove
    @policies_to_add = policies_to_add
    @logger = logger
  end

  def process
    unless document
      log "warning: failed to find #{@document_type} document with slug" +
        " #{@document_slug} - skipping"
      return
    end

    document.editions.each do |edition|
      @policies_to_remove.each do |id|
        edition.delete_policy(id)
        log "Policy removed: #{id}"
      end

      @policies_to_add.each do |id|
        edition.add_policy(id)
        log "Policy added: #{id}"
      end
    end

    if document.published_edition.present?
      register_edition(document.published_edition)
    end
  end

private

  private_class_method def self.sanitised_policies(policies)
    policies ? policies.split : []
  end

  def document
    @document ||= Document.where(slug: @slug).last
  end

  def register_edition(edition)
    log "registering '#{edition.slug}' #{document.document_type}"
    edition.reload
    register_with_publishing_api(edition)
    register_with_search(edition)
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
