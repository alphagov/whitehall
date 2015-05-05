require 'data_hygiene/policy_to_paper_mapper'

module DataHygiene
    # Used to identify the appropriate redirect path for a whitehall policy.
    #
    # Note: Can be removed after the migration to new policies has been complete.
  class PolicyRedirectIdentifier

    def initialize(policy)
      @policy = policy
    end

    def redirect_path
      if corresponding_future_policy.present?
        corresponding_future_policy_path
      else
        corresponding_policy_publication_path
      end
    end

  private
    attr_reader :policy

    def corresponding_future_policy
      @future_policy ||= Future::Policy.find(policy.content_id)
    end

    def corresponding_future_policy_path
      corresponding_future_policy.base_path
    end

    def corresponding_policy_publication_path
      corresponding_policy_publication = PolicyToPaperMapper.new.publication_for(policy)
      Whitehall.url_maker.document_path(corresponding_policy_publication)
    end
  end
end
