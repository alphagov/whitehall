module Admin::DocumentCollectionGroupMembershipsHelper
  def document_collection_group_member_title(membership)
    return membership.non_whitehall_link.title if membership.non_whitehall_link

    membership.document.latest_edition.title
  end

  def document_collection_group_member_url(membership)
    return Plek.website_root + membership.non_whitehall_link.base_path if membership.non_whitehall_link

    membership.document.latest_edition.public_url
  end

  def document_collection_group_member_unavailable?(membership)
    !membership.non_whitehall_link && !membership.document&.latest_edition
  end

  def unavailable_document_count(memberships)
    memberships.count do |membership|
      document_collection_group_member_unavailable?(membership)
    end
  end
end
