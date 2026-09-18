module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  included do
    has_one :parent_relationship,
            class_name: "ParentChildRelationship",
            foreign_key: :child_document_id,
            primary_key: :document_id
    has_one :parent_edition, through: :parent_relationship

    validate :parent_edition_must_exist
  end

  def parent_edition_id
    parent_relationship&.parent_edition_id
  end

private

  def parent_edition_must_exist
    return if parent_edition_id.blank?
    return if StandardEdition.exists?(parent_edition_id)

    errors.add(:parent_edition_id, "must correspond to an existing StandardEdition")
  end
end
