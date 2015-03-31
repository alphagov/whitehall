module DataHygiene
  class EditionReregisterer
    attr_reader :edition, :logger

    def initialize(edition, logger: Logger.new(nil))
      @edition = edition
      @logger = logger
      raise "Edition '#{edition.id}' is '#{edition.state}'. It must be 'published' to reregister" unless edition.published?
    end

    def call
      logger.info "Re-registering '#{edition.slug}'"
      edition.reload
      register_with_panopticon
      register_with_publishing_api
      register_with_search
      logger.info "Re-registering of '#{edition.slug}' complete."
    end

  private
    def register_with_panopticon
      logger.info "..with Panopticon"
      registerer = Whitehall.register_edition_with_panopticon(edition)
    end

    def register_with_publishing_api
      logger.info "..with Publishing API"
      Whitehall::PublishingApi.republish(edition)
    end

    def register_with_search
      logger.info "..with Rummager"
      ServiceListeners::SearchIndexer.new(edition).index!
    end
  end
end
