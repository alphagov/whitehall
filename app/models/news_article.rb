class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  mount_uploader :image, DocumentImageUploader, mount_on: :carrierwave_image

  has_many :policy_areas, through: :published_related_policies, group: 'policy_areas.id'

  def has_summary?
    true
  end
end
