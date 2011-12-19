class Policy < Document
  include Document::NationalApplicability
  include Document::PolicyAreas
  include Document::Ministers
  include Document::FactCheckable
  include Document::SupportingPages
  include Document::Countries

  include Document::RelatedPolicies
  def can_be_related_to_policies?
    false
  end
end