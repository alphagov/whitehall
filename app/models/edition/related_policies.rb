module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  def delete_policy(content_id)
    edition_policies.where(policy_content_id: content_id).delete_all
  end

  def add_policy(content_id)
    unless policy_content_ids.include?(content_id)
      edition_policies.create!(policy_content_id: content_id)
    end
  end

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.policy_content_ids = @edition.policy_content_ids
    end
  end

  included do
    has_many :edition_policies, foreign_key: :edition_id
    add_trait Trait
  end

  def policy_content_ids
    edition_policies.map(&:policy_content_id)
  end

  def policy_content_ids=(content_ids)
    # This is a workaround to preserve the functionality
    # where tagging to a policy automatically tags to the parent
    # policies, so that the content appears in the parent policies' finders.
    all_content_ids = parent_policy_content_ids(content_ids) + Set.new(content_ids)

    self.edition_policies = all_content_ids.map { |content_id|
      EditionPolicy.new(policy_content_id: content_id)
    }
  end

  def parent_policy_content_ids(content_ids)
    parent_ids = Set.new

    content_ids.each do |policy_content_id|
      link_response = publishing_api.get_links(policy_content_id)
      next unless link_response

      if (pa_links = publishing_api.get_links(policy_content_id)["links"]["policy_areas"])
        parent_ids += pa_links
      end
    end

    parent_ids
  end

  def publishing_api
    @publishing_api ||= Whitehall.publishing_api_v2_client
  end

  def policies
    Policy.from_content_ids(policy_content_ids)
  end

  def search_index
    super.merge(
      policies: policies.map(&:slug)
    )
  end

  def can_be_related_to_policies?
    true
  end
end
