module DocumentCollectionHelper
  def part_of_collections_paragraph(collections)
    if collections and collections.any?
      links = collections.map do |c|
        link_to c.name, organisation_document_collection_path(c.organisation, c),
                class: "document-collection", id: "document_collection_#{c.id}"
      end
      content_tag :p, ("Collected in " + links.to_sentence + ".").html_safe, class: 'document-collections js-hide-other-links'
    end
  end

  def document_collection_edition_with_state(edition)
    link_to(edition.title, admin_edition_path(edition)) + " " +
    content_tag(:span,
                 %{(#{edition.state} #{edition.format_name})},
                 class: "document_state")
  end
end
