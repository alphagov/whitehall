module DocumentSeriesHelper
  def part_of_series_paragraph(series)
    if series and series.any?
      links = series.map do |c|
        link_to c.name, organisation_document_series_path(c.organisation, c),
                class: "document-series", id: "document_series_#{c.id}"
      end
      content_tag :p, ("Collected in " + links.to_sentence + ".").html_safe, class: 'document-series js-hide-other-links'
    end
  end

  def document_series_edition_with_state(edition)
    link_to(edition.title, admin_edition_path(edition)) + " " +
    content_tag(:span,
                 %{(#{edition.state} #{edition.format_name})},
                 class: "document_state")
  end
end
