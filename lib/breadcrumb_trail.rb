class BreadcrumbTrail
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  def valid?
    to_hash.present?
  end

  def self.for(content_object)
    case content_object
    when DetailedGuide
      DetailedGuideBreadcrumbTrail.new(content_object)
    when MainstreamCategory
      MainstreamCategoryBreadcrumbTrail.new(content_object)
    end
  end
end

class DetailedGuideBreadcrumbTrail < BreadcrumbTrail
  def initialize(detailed_guide)
    @detailed_guide = detailed_guide
  end

  def to_hash
    return unless @detailed_guide.primary_mainstream_category.parent_tag.present?
    @hash ||= {
      title: @detailed_guide.title,
      format: 'detailedguidance',
      web_url: public_document_path(@detailed_guide),
      tags: [tag_hash(@detailed_guide.primary_mainstream_category)]
    }
  end

private
  def tag_hash(mainstream_category)
    {
      title: mainstream_category.title,
      id: mainstream_category.path,
      web_url: nil,
      details: {
        type: 'section'
      },
      content_with_tag: {
        id: mainstream_category.path,
        web_url: mainstream_category_path(mainstream_category)
      },
      parent: Whitehall.mainstream_content_api.tag(mainstream_category.parent_tag).to_hash
    }
  end

end

class MainstreamCategoryBreadcrumbTrail < BreadcrumbTrail
  def initialize(mainstream_category)
    @mainstream_category = mainstream_category
  end

  def to_hash
    return unless @mainstream_category.parent_tag.present?
    @hash ||= {
      title: @mainstream_category.title,
      format: 'section',
      web_url: mainstream_category_path(@mainstream_category),
      id: @mainstream_category.identifier,
      tags: [Whitehall.mainstream_content_api.tag(@mainstream_category.parent_tag).to_hash]
    }
  end
end