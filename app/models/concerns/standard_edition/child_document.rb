module StandardEdition::ChildDocument
  extend ActiveSupport::Concern

  class IncompatibleParentState < ::WhitehallError; end

  included do
    has_one :parent_relationship,
            class_name: "ParentChildRelationship",
            foreign_key: :child_document_id,
            primary_key: :document_id,
            inverse_of: :child_document

    has_one :parent_edition,
            through: :parent_relationship,
            source: :parent_edition

    before_update :ensure_publishing_is_allowed!, if: :publishing?
  end

  def is_child_document?
    parent_edition.present?
  end

  def can_be_published?
    return true unless is_child_document?

    parent_edition.document.live_edition&.state == "published" && !parent_edition.pre_publication?
  end

private

  def publishing?
    will_save_change_to_state? && state == "published"
  end

  def ensure_publishing_is_allowed!
    return if can_be_published?

    raise IncompatibleParentState, "Unable to publish child document"
  end
end
