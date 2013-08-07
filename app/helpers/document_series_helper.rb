module DocumentSeriesHelper
  def document_series_edition_with_state(edition)
    link_to(edition.title, admin_edition_path(edition)) + " " +
    content_tag(:span,
                %{(#{edition.state} #{edition.format_name})},
                class: "document_state")
  end

  def array_of_links_to_document_series(edition)
    edition.document_series.map do |ds|
      link_to ds.name, organisation_document_series_path(ds.organisation, ds)
    end
  end

  def list_of_li_links_to_document_series(edition)
    edition.document_series.map do |ds|
      content_tag(:li, link_to(ds.name, organisation_document_series_path(ds.organisation, ds)))
    end.join("").html_safe
  end
end
