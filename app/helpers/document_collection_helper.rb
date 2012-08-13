module DocumentCollectionHelper
  def document_collection_edition_with_state(edition)
    link_to(edition.title, admin_edition_path(edition)) + " " +
    content_tag(:span,
                 %{(#{edition.state} #{edition.format_name})},
                 class: "document_state")
  end
end
