# Used during the election period of 2015 to migrate the policy taggings on
# editions such that they map to the new policies being managed by
# policy-publisher.
#
# Note: Can be removed after the migration to new policies has been complete.
#
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
      # Cannot use the #related_policies method directly because it either
      # returns new policies or old depending on the state of the feature-flag
      # see the Edition::RelatedPolicies module.
      content_ids = edition.related_policy_ids.map {|id| Edition.find(id).content_id }
      edition.policy_content_ids = content_ids
    end
  end
end
