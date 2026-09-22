module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  included do
    has_one :parent_relationship,
            class_name: "ParentChildRelationship",
            foreign_key: :child_document_id,
            primary_key: :document_id
    has_one :parent_edition, through: :parent_relationship

    validate :parent_edition_must_exist
    validate :child_document_type_must_be_allowed_by_parent
  end

  def parent_edition_id
    parent_relationship&.parent_edition_id
  end

  def parent_edition_id=(parent_edition_id)
    if parent_edition_id.present?
      self.parent_relationship ||= build_parent_relationship
      parent_relationship.parent_edition_id = parent_edition_id
    else
      self.parent_relationship = nil
    end
  end

private

  def parent_edition_must_exist
    return if parent_edition_id.blank?
    return if StandardEdition.exists?(parent_edition_id)

    errors.add(:parent_edition_id, "must correspond to an existing StandardEdition")
  end

  def child_document_type_must_be_allowed_by_parent
    return if parent_edition_id.blank?

    parent = StandardEdition.find_by(id: parent_edition_id)
    return if parent.nil? # handled by parent_edition_must_exist
    return if parent.type_instance.allows_child_document_type?(configurable_document_type)

    errors.add(:parent_edition_id, "must be configured to allow this child document")
  end
end
