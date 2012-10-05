class Api::MainstreamCategoryTagPresenter
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper
  include MainstreamCategoryRoutesHelper

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
        description: mainstream_category.description
      },
      content_with_tag: {
        id: mainstream_category.path,
        web_url: mainstream_category_path(mainstream_category)
      }
    }
  end

 end
