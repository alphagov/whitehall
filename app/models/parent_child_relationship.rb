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

private

  def parent_must_be_prepublication
    return if parent_edition.blank?
    return if parent_edition.pre_publication?

    errors.add(:parent_edition, "must be in a pre-publication state")
  end
end
