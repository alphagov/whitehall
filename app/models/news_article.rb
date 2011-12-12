class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::Countries

  has_many :related_published_policies, class_name: 'Policy', conditions: {state: :published}, through: :document_relations, source: :related_document
  has_many :policy_areas, through: :related_published_policies, group: 'policy_areas.id'

  class << self
    def featured
      where featured: true
    end
  end
end