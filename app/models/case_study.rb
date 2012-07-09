class CaseStudy < Edition
  include Edition::RelatedPolicies
  include Edition::FactCheckable

  has_many :topics, through: :published_related_policies, uniq: true


end
