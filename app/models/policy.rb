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

  private

  def remove_document_relations
    document_relations.each(&:destroy)
  end
end