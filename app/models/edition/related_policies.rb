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
      begin
        link_response = Services.publishing_api.get_links(policy_content_id)
      rescue GdsApi::HTTPNotFound
        next
      end

      if (pa_links = link_response["links"]["policy_areas"])
        parent_ids += pa_links
      end
    end

    parent_ids
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

  def has_policies?
    policy_content_ids.any?
  end
end
