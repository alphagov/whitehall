class TaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :selected_taxons, :all_taxons, :content_id, :previous_version

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
    govuk_taxonomy.matching_against_published_taxons(selected_taxons)
  end

  def visible_draft_taxons
    govuk_taxonomy.matching_against_visible_draft_taxons(selected_taxons)
  end

  def invisible_draft_taxons
    selected_taxons - (published_taxons + visible_draft_taxons)
  end

  def publish!
    Services
      .publishing_api
      .patch_links(
        content_id,
        links: { taxons: most_specific_taxons },
        previous_version: previous_version
      )
  end

  # Ignore any taxons that already have a more specific taxon selected
  def most_specific_taxons
    all_taxons.each_with_object([]) do |taxon, list_of_taxons|
      content_ids = taxon.descendants.map(&:content_id)

      any_descendants_selected = selected_taxons.any? do |selected_taxon|
        content_ids.include?(selected_taxon)
      end

      unless any_descendants_selected
        content_id = taxon.content_id
        list_of_taxons << content_id if selected_taxons.include?(content_id)
      end
    end
  end

private

  def govuk_taxonomy
    @_taxonomy ||= Taxonomy::GovukTaxonomy.new
  end
end
