require_relative "../publishing_api_presenters"

class PublishingApiPresenters::Unpublishing < PublishingApiPresenters::Item
  def content
    item.redirect? ? redirect_hash : super
  end

private

  def filter_links
    # nothing to tag
    []
  end

  def document_format
    item.redirect? ? 'redirect' : 'unpublishing'
  end

  def base_path
    item.document_path
  end

  def redirect_hash
    {
      base_path: base_path,
      format: 'redirect',
      publishing_app: 'whitehall',
      redirects: [
        { path: base_path, type: 'exact', destination: alternative_path }
      ],
    }
  end

  def edition
    @edition ||= ::Edition.unscoped.find(item.edition_id)
  end

  def rendering_app
    edition.rendering_app
  end

  def title
    edition.title
  end

  def description
    edition.summary
  end

  def public_updated_at
    edition.public_timestamp
  end

  def need_ids
    edition.need_ids
  end

  def alternative_path
    full_uri = Addressable::URI.parse(item.alternative_url)

    path_uri = Addressable::URI.new(
      path: full_uri.path,
      query: full_uri.query,
      fragment: full_uri.fragment
    )

    path_uri.to_s
  end

  def details
    {
      explanation: unpublishing_explanation,
      unpublished_at: item.created_at,
      alternative_url: item.alternative_url
    }
  end

  def unpublishing_explanation
    if item.try(:explanation).present?
      Whitehall::GovspeakRenderer.new.govspeak_to_html(item.explanation)
    end
  end
end
