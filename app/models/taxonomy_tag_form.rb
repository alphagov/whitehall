class TaxonomyTagForm
  include ActiveModel::Model

  attr_accessor :selected_taxons, :content_id, :previous_version

  def self.load(content_id)
    begin
      content_item = Services.publishing_api.get_links(content_id)

      selected_taxons = content_item["links"]["taxons"] || []
      previous_version = content_item["version"] || 0
    rescue GdsApi::HTTPNotFound
      # TODO: This is a workaround, because Publishing API
      # returns 404 when the document exists but there are no links.
      # This can be removed when that changes.
      selected_taxons = []
      previous_version = 0
    end

    new(
      selected_taxons:,
      content_id:,
      previous_version:,
    )
  end

private

  def topic_taxonomy
    @topic_taxonomy ||= Taxonomy::TopicTaxonomy.new
  end
end
