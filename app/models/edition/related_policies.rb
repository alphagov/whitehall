module Edition::RelatedPolicies
  extend ActiveSupport::Concern

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
    self.edition_policies = content_ids.map do |content_id|
      EditionPolicy.new(policy_content_id: content_id)
    end
  end

  def policies
    Policy.from_content_ids(policy_content_ids)
  end

  def policy_areas
    policies.flat_map(&:policy_areas).uniq
  end

  def search_index
    super.merge(
      policies: [
        policy_areas.map(&:slug),
        policies.map(&:slug),
      ].flatten.uniq
    )
  end

  def can_be_related_to_policies?
    true
  end
end
