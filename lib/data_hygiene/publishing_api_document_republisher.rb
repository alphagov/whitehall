module DataHygiene
  # Can be used to republish types of Editions to the publishing-api.
  #
  # Usage:
  #
  #   publisher = DataHygiene::PublishingApiDocumentRepublisher.new(CaseStudy)
  #   publisher.perform
  class PublishingApiDocumentRepublisher
    attr_reader :edition_class, :logger, :queued

    def initialize(edition_class, logger = Logger.new(STDOUT))
      unless edition_class.is_a?(Class) && edition_class < Edition # http://ruby-doc.org/core-2.3.0/Module.html#method-i-3C
        raise ArgumentError, "The argument to PublishingApiDocumentRepublisher must be a subclass of Edition"
      end

      @edition_class = edition_class
      @logger = logger
      @queued = 0
    end

    def perform
      logger.info "Queuing #{documents.count} #{edition_class} instances for republishing to the Publishing API"
      documents.find_each do |document|
        Whitehall::PublishingApi.republish_document_async(document, bulk: true)
        logger << '.'
        @queued += 1
      end
      logger.info("Queued #{queued} instances for republishing")
    end

  private

    def documents
      Document.where("id in (SELECT document_id from editions where type=?)", edition_class)
    end
  end
end
