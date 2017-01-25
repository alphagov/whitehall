class EditionTaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :selected_taxons, :edition_content_id, :previous_version

  def self.load(content_id)
    content_item = Whitehall
      .publishing_api_v2_client
      .get_links(content_id)

    new(
      selected_taxons: content_item["links"]["taxons"] || [],
      edition_content_id: content_id,
      previous_version: content_item["version"] || 0
    )
  end

  def publish!
    Whitehall
      .publishing_api_v2_client
      .patch_links(
        edition_content_id,
        links: { taxons: taxons_to_publish },
        previous_version: previous_version
      )
  end

  def education_taxons
    Taxonomy.education
  end

private

  def taxons_to_publish
    Taxonomy::FindChildest.new(
      tree: education_taxons.tree,
      selected_taxons: selected_taxons
    ).taxons
  end
end
