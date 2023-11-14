module Admin::DocumentCollectionGroupMembershipsHelper
  UNAVAILABLE_DOCUMENT_TITLE = "Unavailable Document".freeze

  def document_collection_group_member_title(membership)
    return membership.non_whitehall_link.title if membership.non_whitehall_link
    return unavailable_document_title_tag unless membership.document&.latest_edition

    membership.document.latest_edition.title
  end

  def document_collection_group_member_links(collection, group, membership)
    links = [remove_link(collection, group, membership)]
    links.prepend(view_link(membership)) unless document_collection_group_member_unavailable?(membership)
    sanitize(links.join)
  end

  def unavailable_document_count(memberships)
    memberships.count do |membership|
      document_collection_group_member_unavailable?(membership)
    end
  end

private

  def document_collection_group_member_url(membership)
    return Plek.website_root + membership.non_whitehall_link.base_path if membership.non_whitehall_link

    membership.document.latest_edition.public_url
  end

  def unavailable_document_title_tag
    tag.span(UNAVAILABLE_DOCUMENT_TITLE, class: "govuk-!-font-weight-bold")
  end

  def document_collection_group_member_unavailable?(membership)
    !membership.non_whitehall_link && !membership.document&.latest_edition
  end

  def view_link(membership)
    link_to(
      sanitize("View #{tag.span(document_collection_group_member_title(membership), class: 'govuk-visually-hidden')}"),
      document_collection_group_member_url(membership),
      class: "govuk-link",
    )
  end

  def remove_link(collection, group, membership)
    link_to(
      sanitize("Remove #{tag.span(document_collection_group_member_title(membership), class: 'govuk-visually-hidden')}"),
      confirm_destroy_admin_document_collection_group_document_collection_group_membership_path(collection, group, membership),
      class: "govuk-link gem-link--destructive govuk-!-margin-left-3",
    )
  end
end
