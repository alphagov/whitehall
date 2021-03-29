module DocumentCollectionHelper
  def array_of_links_to_document_collections(edition)
    edition.published_document_collections.map do |dc|
      link_to dc.title, public_document_path(dc), class: "collection-link"
    end
  end

  def list_of_li_links_to_document_collections(edition)
    edition
      .published_document_collections
      .map { |dc| link_to dc.title, public_document_path(dc) }
      .map { |link_html| tag.li link_html }
      .join
      .html_safe
  end
end
