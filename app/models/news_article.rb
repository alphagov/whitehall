class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  has_many :related_published_policies, class_name: 'Policy', conditions: {state: :published}, through: :document_relations, source: :related_document
  has_many :policy_areas, through: :related_published_policies, group: 'policy_areas.id'
end