class Publication < Document
  include Document::NationalApplicability
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::Attachable

  has_one :publication_metadatum

  PublicationMetadatum::ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :publication_metadatum
  end

  delegate :research?, to: :publication_metadatum

  validates :publication_date, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :order_url, format: URI::regexp(%w(http https)), allow_blank: true

  after_save :save_publication_metadatum

  def initialize(attributes = {}, options = {})
    super({})
    build_publication_metadatum
    assign_attributes(attributes)
  end

  def document_attributes
    super.merge(publication_metadatum.attributes.slice(*PublicationMetadatum::ATTRIBUTES))
  end

  private

  def save_publication_metadatum
    publication_metadatum.save!
  end
end