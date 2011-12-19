class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  has_many :policy_areas, through: :published_related_policies, group: 'policy_areas.id'
end