module StandardEdition::ParentDocument
  extend ActiveSupport::Concern

  class UnableToDelete < ::WhitehallError; end
  class UnableToWithdraw < ::WhitehallError; end
  class UnableToUnpublish < ::WhitehallError; end

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(new_edition)
      ParentChildRelationship
        .where(parent_edition_id: @edition.id)
        .find_each do |relationship|
        ParentChildRelationship.create!(
          parent_edition_id: new_edition.id,
          child_document_id: relationship.child_document_id,
        )
      end
    end
  end

  included do
    has_many :child_relationships,
             class_name: "ParentChildRelationship",
             foreign_key: :parent_edition_id,
             inverse_of: :parent_edition,
             dependent: :destroy

    has_many :child_documents,
             lambda {
               joins(:editions)
                 .merge(Edition.all) # applies default scope (i.e. excludes deleted)
                 .distinct
             },
             through: :child_relationships,
             source: :child_document

    before_update :ensure_no_new_child_documents!, if: :deleting?
    before_update :ensure_no_children_more_visible_than_parent!, if: :will_save_change_to_state?

    add_trait Trait
  end

  def allows_child_documents?
    (type_instance.settings["allowed_child_document_types"] || []).count.positive?
  end

  def is_parent_document?
    child_documents.any?
  end

  def child_editions
    Edition.where(id: child_documents.select(:latest_edition_id))
  end

  def new_child_documents
    child_documents.where(live_edition_id: nil)
  end

private

  def deleting?
    will_save_change_to_state? && state == "deleted"
  end

  def ensure_no_new_child_documents!
    if allows_child_documents? && new_child_documents.any?
      raise UnableToDelete, "This document cannot be deleted while it has child documents that have never been published. Delete the draft child documents first."
    end
  end

  def ensure_no_children_more_visible_than_parent!
    if state == "unpublished" && child_editions.any? { |child| child.state.in?(%w[published withdrawn]) }
      raise UnableToUnpublish, "This document cannot be unpublished while it has child documents that are published or withdrawn. Unpublish the child documents first."
    end

    if state == "withdrawn" && child_editions.any? { |child| child.state == "published" }
      raise UnableToWithdraw, "This document cannot be withdrawn while it has child documents that are published. Withdraw the child documents first."
    end
  end
end
