class Policy < Edition
  include Edition::NationalApplicability
  include Edition::PolicyTopics
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::SupportingPages
  include Edition::Countries

  has_many :document_relations, through: :doc_identity
  has_many :related_documents, through: :document_relations, source: :edition
  has_many :published_related_documents, through: :document_relations, source: :edition, conditions: {editions: {state: 'published'}}

  validates :summary, presence: true

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(document)
      document.related_documents = @document.related_documents
    end
  end

  add_trait Trait

  after_destroy :remove_document_relations

  def self.stub
    where(stub: true)
  end

  def title_without_stub
    read_attribute(:title)
  end

  def title
    stub? ? "[Sample] #{title_without_stub}" : title_without_stub
  end

  def sluggable_title
    title_without_stub
  end

  def has_summary?
    true
  end

  private

  def remove_document_relations
    document_relations.each(&:destroy)
  end
end
