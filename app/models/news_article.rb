class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  mount_uploader :featuring_image, FeaturingImageUploader, mount_on: :carrierwave_featuring_image

  add_trait do
    def process_associations_before_save(document)
      document.featuring_image = @document.featuring_image.file if @document.featuring_image.present?
    end
  end

  has_many :policy_topics, through: :published_related_policies, group: 'policy_topics.id'

  def has_summary?
    true
  end

  def allows_featuring_image?
    true
  end
end
