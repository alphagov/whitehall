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
    attr_reader :logger, :scope, :republished, :skipped

    def initialize(scope, logger=Logger.new(STDOUT))
      @scope = scope
      @logger = logger
      @republished = 0
      @skipped = 0
    end

    def perform
      logger.info "Pushing #{scope.count} #{scope.model_name} instances to the Publishing API"

      scope.find_each do |instance|
        if publishable?(instance)
          republish(instance)
        else
          skip(instance)
        end
      end

      logger.info("Republished #{republished} instances")
      logger.info("Skipped #{skipped} instances (which were not published)") if skipped > 0
    end

  private

    def publishable?(instance)
      !instance.kind_of?(Edition) || instance.publicly_visible?
    end

    def republish(instance)
      logger << '.'
      Whitehall::PublishingApi.republish(instance)
      @republished += 1
    end

    def skip(instance)
      logger << '*'
      @skipped += 1
    end
  end
end
