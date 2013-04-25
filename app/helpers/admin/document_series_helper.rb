module Admin::DocumentSeriesHelper
  def document_series_select_options(edition, user, document_series_ids)
    user_organisation = user.organisation
    grouped_series = DocumentSeries.with_translations_for(:organisation).all.group_by(&:organisation)
    primary_series = grouped_series.delete(user_organisation)

    series_options = [%{<option value=""></option>}]
    if primary_series
      series_options << (%{<optgroup label="#{user_organisation.name}">} +
      options_from_collection_for_select(primary_series, 'id', 'name', document_series_ids) +
      %{</optgroup>})
    end
    series_options << grouped_series.map do |organisation, series|
      %{<optgroup label="#{organisation.name}">} +
      options_from_collection_for_select(series, 'id', 'name', document_series_ids) +
      %{</optgroup>}
    end
    series_options.join.html_safe
  end
end
