class EditionTaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :selected_taxons, :edition_content_id, :previous_version

  def self.load(content_id)
    begin
      content_item = Whitehall
        .publishing_api_v2_client
        .get_links(content_id)

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
      edition_content_id: content_id,
      previous_version: previous_version
    )
  end

  def publish!
    Whitehall
      .publishing_api_v2_client
      .patch_links(
        edition_content_id,
        links: { taxons: most_specific_taxons },
        previous_version: previous_version
      )
  end

  def education_taxons
    Taxonomy.education
  end

  # Ignore any taxons that already have a more specific taxon selected
  def most_specific_taxons
    education_taxons.tree.each_with_object([]) do |taxon, list_of_taxons|
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
end
