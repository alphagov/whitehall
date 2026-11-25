class EditionDeleter < EditionService
  def verb
    "delete"
  end

  def past_participle
    "deleted"
  end

  def can_transition?
    edition.public_send("can_#{verb}?") &&
      edition.unpublishing.nil?
  end

  def failure_reason
    if !edition.unpublishing.nil?
      "A draft edition cannot be deleted if it has been unpublished"
    elsif !edition.public_send("can_#{verb}?")
      "An edition that is #{edition.current_state} cannot be deleted"
    elsif deletion_would_cause_orphaned_children?
      "You must delete this document's draft children before you can delete this document"
    end
  end

private

  def deletion_would_cause_orphaned_children?
    # child_editions excludes deleted editions, so already-deleted children don't block deletion
    return unless edition.try(:child_editions)

    edition.child_editions.any? do |child_edition|
      ParentChildRelationship.where(child_document_id: child_edition.document_id).where.not(parent_edition_id: edition.id).empty?
    end
  end

  def fire_transition!
    edition.public_send(verb)
    edition.save!(validate: false)
    edition.delete_all_attachments if edition.respond_to?(:delete_all_attachments)
    edition.edition_roles.clear if edition.respond_to?(:edition_roles)
    edition.remove_orphaned_offsite_links if edition.respond_to?(:remove_orphaned_offsite_links)
    edition.remove_from_parent_navigation if edition.respond_to?(:remove_from_parent_navigation)
  end
end
