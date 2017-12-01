class TaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :selected_taxons, :invisible_taxons, :all_taxons, :content_id, :previous_version

  def self.load(content_id)
    begin
      content_item = Services.publishing_api.get_links(content_id)

      selected_taxons = content_item["links"]["taxons"] || []
      previous_version = content_item["version"] || 0
    rescue GdsApi::HTTPNotFound
      # TODO: This is a workaround, because Publishing API
      # returns 404 when the document exists but there are no links.
      # This can be removed when that changes.
      selected_taxons = []
      previous_version = 0
    end

    new(
      selected_taxons: selected_taxons,
      content_id: content_id,
      previous_version: previous_version
    )
  end

  def published_taxons
    @_published_ids ||= govuk_taxonomy.matching_against_published_taxons(selected_taxons)
  end

  def visible_draft_taxons
    @_visible_draft_ids ||= govuk_taxonomy.matching_against_visible_draft_taxons(selected_taxons)
  end

  def invisible_draft_taxons
    selected_taxons - (published_taxons + visible_draft_taxons)
  end

private

  def govuk_taxonomy
    @_taxonomy ||= Taxonomy::GovukTaxonomy.new
  end
end
