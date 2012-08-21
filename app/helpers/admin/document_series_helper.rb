module Admin::DocumentSeriesHelper
  def document_series_select_options(edition, user)
    organisation = user.organisation
    grouped_series = DocumentSeries.all.group_by(&:organisation)
    primary_series = grouped_series.delete(user.organisation)

    series_options = [%{<option value=""></option>}]
    if primary_series
      series_options << (%{<optgroup label="#{user.organisation.name}">} +
      options_from_collection_for_select(primary_series, 'id', 'name', edition.document_series_id) +
      %{</optgroup>})
    end
    series_options << grouped_series.map do |organisation, series|
      %{<optgroup label="#{organisation.name}">} +
      options_from_collection_for_select(series, 'id', 'name', edition.document_series_id) +
      %{</optgroup>}
    end
    series_options.join.html_safe
  end
end
