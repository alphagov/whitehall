class Api::MainstreamCategoryTagPresenter
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  def initialize(categories)
    @categories = categories
  end

  def as_json
    {
      results: @categories.map { |c| tag_hash(c) }
    }
  end

  private

  def tag_hash(mainstream_category)
    {
      title: mainstream_category.title,
      id: mainstream_category.path,
      web_url: nil,
      details: {
        type: 'section',
      },
      content_with_tag: {
        id: mainstream_category.path,
        web_url: mainstream_category_path(mainstream_category)
      }
    }
  end

  def detailed_guide_url(guide)
    h.api_detailed_guide_url guide.document, host: h.public_host
  end

  def related_json
    model.published_related_detailed_guides.map do |guide|
      {
        id: detailed_guide_url(guide),
        title: guide.title,
        web_url: h.public_document_url(guide)
      }
    end
  end
end
