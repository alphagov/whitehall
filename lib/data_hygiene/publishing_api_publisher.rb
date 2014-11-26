module DataHygiene
  # Can be used to (re)publish a bunch of models to the Publishing API.
  #
  # Usage:
  #
  #   scope = CaseStudy.published
  #   publisher = DataHygiene::PublishingApiPublisher.new(scope)
  #   publisher.perform
  #
  class PublishingApiPublisher
    attr_reader :logger, :scope

    def initialize(scope, logger=Logger.new(STDOUT))
      @scope = scope
      @logger = logger
    end

    def perform
      logger.info "Pushing #{scope.count} #{scope.model_name} instances to the Publishing API"
      scope.find_each do |instance|
        logger << '.'
        PublishingApiWorker.perform_async(instance.class.name, instance.id)
      end
    end
  end
end
