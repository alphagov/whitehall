class SupportingPage < Edition
  include Edition::AlternativeFormatProvider
  include Edition::Images
  include Edition::RelatedPolicies
  include ::Attachable

  validate :at_least_one_related_policy

  has_many :organisations, through: :related_policies, readonly: true

private
  def at_least_one_related_policy
    unless related_documents.any? { |d| d.document_type == "Policy" }
      errors.add(:related_policies, "must include at least one policy")
    end
  end

  def summary_required?
    false
  end
end
