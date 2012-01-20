class NewsArticle < Document
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Countries
  include Document::Featurable

  mount_uploader :image, DocumentImageUploader, mount_on: :carrierwave_image

  add_trait do
    def process_associations_before_save(document)
      document.image = @document.image.file if @document.image.present?
    end
  end

  has_many :policy_areas, through: :published_related_policies, group: 'policy_areas.id'
  belongs_to :featured_document_image

  def has_summary?
    true
  end
end
