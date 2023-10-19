module Admin::DocumentCollectionGroupMembershipsHelper
  def document_collection_group_member_title(membership)
    if membership.non_whitehall_link
      membership.non_whitehall_link.title
    else
      membership.document.latest_edition.title
    end
  end

  def document_collection_group_member_url(membership)
    if membership.non_whitehall_link
      Plek.website_root + membership.non_whitehall_link.base_path
    else
      membership.document.latest_edition.public_url
    end
  end
end
