class DocumentCollection < Edition
  include Edition::Organisations
  include Edition::RelatedPolicies
  include Edition::Topics

  has_many :groups, class_name: 'DocumentCollectionGroup',
                    order: 'document_collection_groups.ordering',
                    dependent: :destroy,
                    inverse_of: :document_collection

  has_many :documents, through: :groups
  has_many :editions, through: :documents

  before_create :create_default_group

  class ClonesGroupsTrait < Edition::Traits::Trait
    def process_associations_before_save(new_edition)
      new_edition.groups = @edition.groups.map(&:dup)
    end
  end

  add_trait ClonesGroupsTrait

  def search_index
    super.merge("slug" => slug)
  end

  def search_link
    Whitehall.url_maker.public_document_path(self)
  end

  def indexable_content
    [
      Govspeak::Document.new(body).to_text,
      groups.map do |group|
        [group.heading, Govspeak::Document.new(group.body).to_text]
      end
    ].flatten.join("\n")
  end

  def display_type
    "Collection"
  end

  def published_editions
    editions.published.reorder(nil).in_reverse_chronological_order
  end

  def scheduled_editions
    editions.scheduled
  end

  private

  def create_default_group
    if groups.empty?
      groups << DocumentCollectionGroup.new(DocumentCollectionGroup.default_attributes)
    end
  end

  def body_required?
    false
  end
end
