class MainstreamBrowseTags
  attr_reader :artefact_slug

  def initialize(artefact_slug)
    @artefact_slug = artefact_slug
  end

  def tags
    entry = cached_artefacts_tagged_to_browse_pages.find do |entry|
      entry['artefact_slug'] == artefact_slug
    end

    entry['mainstream_browse_page_slugs'] if entry
  end

private

  def cached_artefacts_tagged_to_browse_pages
    Rails.cache.fetch 'artefacts_tagged_to_mainstream_browse_pages', expires_in: 5.minutes do
      Whitehall.content_api.artefacts_tagged_to_mainstream_browse_pages.to_a
    end
  end
end
