module DataHygiene
  # Can be used to republish a bunch of models to the Publishing API.
  #
  # Usage:
  #
  #   scope = CaseStudy.published
  #   publisher = DataHygiene::PublishingApiRepublisher.new(scope)
  #   publisher.perform
  #
  class PublishingApiRepublisher
    attr_reader :logger, :scope

    def initialize(scope, logger=Logger.new(STDOUT))
      @scope = scope
      @logger = logger
    end

    def perform
      logger.info "Pushing #{scope.count} #{scope.model_name} instances to the Publishing API"
      scope.find_each do |instance|
        logger << '.'
        PublishingApiWorker.perform_async(instance.class.name, instance.id, update_type: "republish")
      end
    end
  end
end
