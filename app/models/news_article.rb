class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  has_many :policy_topics, through: :published_related_policies, uniq: true

  def has_summary?
    true
  end

  def lead_image
    images.first
  end
end
