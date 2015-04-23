module DataHygiene
  # Can be used to republish a bunch of models to the Publishing API.
  #
  # Usage:
  #
  #   scope = CaseStudy.published
  #   publisher = DataHygiene::PublishingApiRepublisher.new(scope)
  #   publisher.perform
  #
  # Note: Whitehall::PublishingApi will raise an exception if an attempt is made
  # to publish an instance that is not currently supported (e.g. draft editions
  # cannot be pubilshed yet). The scope passed in should not include any
  # instances that are not publishable.
  class PublishingApiRepublisher
    attr_reader :logger, :scope, :republished

    def initialize(scope, logger=Logger.new(STDOUT))
      @scope = scope
      @logger = logger
      @republished = 0
    end

    def perform
      logger.info "Queuing #{scope.count} #{scope.model_name} instances for republishing to the Publishing API"

      scope.find_each { |instance| republish(instance) }

      logger.info("Queued #{republished} instances for republishing")
    end

  private

    def republish(instance)
      Whitehall::PublishingApi.republish_async(instance)
      logger << '.'
      @republished +=1
    end
  end
end
