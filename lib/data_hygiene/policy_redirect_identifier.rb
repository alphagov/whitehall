require 'data_hygiene/policy_to_paper_mapper'

module DataHygiene
    # Used to identify the appropriate redirect URL for a whitehall policy.
    #
    # Note: Can be removed after the migration to new policies has been complete.
  class PolicyRedirectIdentifier

    def initialize(policy)
      @policy = policy
    end

    def redirect_url
      if corresponding_future_policy.present?
        corresponding_future_policy_url
      else
        corresponding_policy_publication_url
      end
    end

  private
    attr_reader :policy

    def corresponding_future_policy
      @future_policy ||= Future::Policy.find(policy.content_id)
    end

    def corresponding_future_policy_url
      Whitehall.public_root + corresponding_future_policy.base_path
    end

    def corresponding_policy_publication_url
      corresponding_policy_publication = PolicyToPaperMapper.new.publication_for(policy)
      Whitehall.url_maker.document_url(corresponding_policy_publication)
    end
  end
end
