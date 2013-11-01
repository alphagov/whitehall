class SupportingPage < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include ::Attachable

  validates :related_policies, length: { minimum: 1, message: "must include at least one policy" }
end
