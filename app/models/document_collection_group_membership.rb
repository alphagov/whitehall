class DocumentCollectionGroupMembership < ApplicationRecord
  belongs_to :document,
             inverse_of: :document_collection_group_memberships,
             optional: true
  belongs_to :non_whitehall_link,
             class_name: "DocumentCollectionNonWhitehallLink",
             inverse_of: :document_collection_group_memberships,
             optional: true
  belongs_to :document_collection_group, inverse_of: :memberships

  before_create :assign_ordering

  validates :document_collection_group, presence: true
  validate :presence_of_document_or_non_whitehall_link

  def content_id
    document&.content_id || non_whitehall_link&.content_id
  end

private

  def assign_ordering
    memberships = document_collection_group.memberships
    self.ordering = if memberships.include?(self)
                      memberships.index(self)
                    else
                      maximum = memberships.maximum(:ordering)
                      maximum.nil? ? 0 : maximum + 1
                    end
  end

  def presence_of_document_or_non_whitehall_link
    if document && non_whitehall_link
      errors.add(:base, "cannot be associated with a document and a non-whitehall link")
    end

    if !document && !non_whitehall_link
      errors.add(:base, "must be associated with a document or a non-whitehall link")
    end
  end
end
