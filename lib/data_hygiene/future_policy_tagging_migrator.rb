module DataHygiene
  class FuturePolicyTaggingMigrator
    def initialize(scope, logger=NullLogger.instance)
      @scope = scope
      @logger = logger
    end

    def migrate!
      logger.info "Migrating #{scope.count} editions "

      scope.find_each do |edition|
        tag_to_new_policies(edition)
        logger << '.'
      end

      logger.info "Migration complete"
    end

  private
    attr_accessor :logger, :scope

    def tag_to_new_policies(edition)
      edition.policy_content_ids = edition.related_policies.map(&:content_id)
    end
  end
end
