module DocumentCollectionHelper
  def document_collection_edition_with_state(edition)
    link_to(edition.title, admin_edition_path(edition)) + " " +
      content_tag(:span,
                  %{(#{edition.state} #{edition.format_name})},
                  class: "document_state")
  end

  def array_of_links_to_document_collections(edition)
    edition.published_document_collections.map do |dc|
      link_to dc.title, public_document_path(dc), class: 'collection-link'
    end
  end

  def list_of_li_links_to_document_collections(edition)
    edition
      .published_document_collections
      .map { |dc| link_to dc.title, public_document_path(dc) }
      .map { |link_html| content_tag :li, link_html }
      .join
      .html_safe
  end
end
