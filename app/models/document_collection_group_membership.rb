class DocumentCollectionGroupMembership < ActiveRecord::Base
  belongs_to :document
  belongs_to :document_collection_group

  before_create :assign_ordering

  def assign_ordering
    self.ordering = document_collection_group.documents.size + 1
  end
end
