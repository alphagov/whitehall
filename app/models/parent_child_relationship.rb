class ParentChildRelationship < ApplicationRecord
  belongs_to :parent_edition,
             class_name: "Edition"

  belongs_to :child_document,
             class_name: "Document"

  validates :parent_edition, presence: true
  validates :child_document, presence: true

  validates :child_document_id,
            uniqueness: { scope: :parent_edition_id }

  validate :parent_must_be_prepublication, on: :create
  validate :child_document_must_have_no_other_parent, on: :create

private

  def parent_must_be_prepublication
    return if parent_edition.blank? # This is already covered by presence validation

    if !parent_edition.pre_publication?
      errors.add(:parent_edition, "must be in a pre-publication state")
    elsif !parent_edition.allows_child_documents?
      errors.add(:parent_edition, "does not support child documents")
    end
  end

  def child_document_must_have_no_other_parent
    return if parent_edition.blank? || child_document.blank? # These are already covered by presence validation

    existing_relationships = ParentChildRelationship.where(child_document_id: child_document_id)
    if existing_relationships.count.positive?
      document_ids = existing_relationships.map { |r| r.parent_edition.document.id }.uniq
      unless parent_edition.document.id.in?(document_ids)
        errors.add(:child_document, "is already linked to a different parent document")
      end
    end
  end
end
