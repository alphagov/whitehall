class EditionTaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :taxons, :edition_content_id, :previous_version

  def self.load(content_id)
    content_item = Whitehall
      .publishing_api_v2_client
      .get_links(content_id)

    new(
      taxons: content_item["links"]["taxons"] || [],
      edition_content_id: content_id,
      previous_version: content_item["version"] || 0
    )
  end

  def publish!
    Whitehall
      .publishing_api_v2_client
      .patch_links(
        edition_content_id,
        links: {taxons: taxons},
        previous_version: previous_version
      )
  end
end
