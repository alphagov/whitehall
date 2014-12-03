module DataHygiene
  # Can be used to republish a bunch of models to the Publishing API.
  #
  # Usage:
  #
  #   scope = CaseStudy.published
  #   publisher = DataHygiene::PublishingApiRepublisher.new(scope)
  #   publisher.perform
  #
  # Note: when the scope passed in is for Editions, this will skip over any
  # that are not in a publically visible state (i.e. not published or archived).
  # Once the Publishing API has support for handling draft content, this should
  # be updated so that draft content can be pushed to the draft stack.
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
      !instance.kind_of?(Edition) || instance.publicly_visible? || instance.unpublishing.present?
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
