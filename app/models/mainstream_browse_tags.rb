class MainstreamBrowseTags
  def initialize(edition)
    @edition = edition
  end

  def tags
    entry = cached_artefacts_tagged_to_browse_pages.find do |entry|
      entry['artefact_slug'] == artefact_slug
    end

    entry['mainstream_browse_page_slugs'] if entry
  end

private

  def artefact_slug
    @artefact_slug ||= Whitehall.url_maker.public_document_path(@edition).sub(/\A\//, "")
  end

  def cached_artefacts_tagged_to_browse_pages
    Rails.cache.fetch 'artefacts_tagged_to_mainstream_browse_pages', expires_in: 5.minutes do
      Whitehall.content_api.artefacts_tagged_to_mainstream_browse_pages.to_a
    end
  end
end
