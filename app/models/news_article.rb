class NewsArticle < Edition
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Countries
  include Edition::Featurable

  has_many :policy_topics, through: :published_related_policies, uniq: true

  def has_summary?
    true
  end

  def lead_image
    images.first
  end
end
