module Admin::DocumentSeriesHelper
  def document_series_select_options(edition, user, document_series_ids)
    orgs = Organisation.scoped.includes(:document_series, :translations).to_a
    ours = orgs.detect { |org| org == user.organisation }
    collection = orgs.reject { |org| org == user.organisation }.unshift(ours)
    option_groups_from_collection_for_select(
        collection, :document_series, :name, :id, :name)
  end
end
