class Policy < Document
  include Document::NationalApplicability
  include Document::PolicyAreas
  include Document::Ministers
  include Document::FactCheckable
  include Document::SupportingPages
  include Document::Countries

  has_many :document_relations, through: :document_identity
  has_many :related_documents, through: :document_relations, source: :document
  has_many :published_related_documents, through: :document_relations, source: :document, conditions: {documents: {state: 'published'}}

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      document.related_documents = @document.related_documents
    end
  end

  add_trait Trait

  after_destroy :remove_document_relations

  scope :stub, where(stub: true)

  define_attribute_methods

  def title_with_stub
    original_title = title_without_stub
    stub? ? "[Sample] #{original_title}" : original_title
  end
  alias_method_chain :title, :stub

  def sluggable_title
    title_without_stub
  end

  private

  def remove_document_relations
    document_relations.each(&:destroy)
  end
end