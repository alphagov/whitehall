module Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  extend ActiveSupport::Concern

  def can_apply_to_local_government?
    true
  end

  def relevant_to_local_government?
    published_related_policies.any?(&:relevant_to_local_government?)
  end

  def self.edition_types
    Edition.concrete_descendants.select { |concrete_edition_type| concrete_edition_type.ancestors.include?(self) }
  end
end
