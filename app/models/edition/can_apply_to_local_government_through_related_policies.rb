module Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  extend ActiveSupport::Concern

  def can_apply_to_local_government?
    true
  end

  def relevant_to_local_government?
    related_policies.any?(&:relevant_to_local_government?)
  end
end
