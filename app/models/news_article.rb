class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  mount_uploader :image, DocumentImageUploader, mount_on: :carrierwave_image
  mount_uploader :featuring_image, FeaturingImageUploader, mount_on: :carrierwave_featuring_image

  validate :image_must_have_a_description

  add_trait do
    def process_associations_before_save(document)
      document.image = @document.image.file if @document.image.present?
      document.featuring_image = @document.featuring_image.file if @document.featuring_image.present?
    end
  end

  has_many :policy_areas, through: :published_related_policies, group: 'policy_areas.id'

  def image_must_have_a_description
    if image.present? && image_alt_text.blank?
      errors.add :image_alt_text, 'All images must have a description'
    end
  end

  def has_summary?
    true
  end

  def allows_featuring_image?
    true
  end
end
