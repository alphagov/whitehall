
module Edition::HasDocumentCollections
  extend ActiveSupport::Concern

  included do
    has_many :document_collections, through: :document
    has_many :document_collection_groups, through: :document
  end

  def can_be_grouped_in_collections?
    true
  end

  def part_of_collection?
    document_collections.any?
  end

  def search_index
    super.merge("document_collections" => document_collections.map(&:slug))
  end

  # We allow document collection groups to be assigned directly on an
  # edition for speed tagging
  def document_collection_group_ids=(ids)
    if new_record?
      raise(StandardError, 'cannot assign document collection to an unsaved edition')
    end
    document.document_collection_group_ids = ids
  end
end
