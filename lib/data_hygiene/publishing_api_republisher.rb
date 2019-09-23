module DataHygiene
  # Can be used to republish things which are not Editions to the Publishing API.
  #
  # Usage:
  #
  #   scope = TakePartPage.all
  #   publisher = DataHygiene::PublishingApiRepublisher.new(scope)
  #   publisher.perform
  class PublishingApiRepublisher
    attr_reader :logger, :scope, :queued

    def initialize(scope, logger = Logger.new(STDOUT))
      @scope = scope
      @logger = logger
      @queued = 0
    end

    def perform
      logger.info "Queuing #{scope.count} #{scope.model_name} instances for republishing to the Publishing API"

      scope.find_each { |instance| republish(instance) }

      logger.info("Queued #{queued} instances for republishing")
    end

  private

    def republish(instance)
      Whitehall::PublishingApi.bulk_republish_async(instance)
      logger << "."
      @queued += 1
    end
  end
end
