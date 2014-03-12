class BreadcrumbTrail
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

  def url_maker
    Whitehall.url_maker
  end
end

class DetailedGuideBreadcrumbTrail < BreadcrumbTrail
  def initialize(detailed_guide)
    @detailed_guide = detailed_guide
  end

  def valid?
    @detailed_guide.primary_mainstream_category.present? && super
  end

  def to_hash
    return unless @detailed_guide.primary_mainstream_category.parent_tag.present?
    @hash ||= {
      title: @detailed_guide.title,
      format: 'detailedguidance',
      web_url: url_maker.public_document_path(@detailed_guide),
      tags: [tag_hash(@detailed_guide.primary_mainstream_category)]
    }
  end

private
  def tag_hash(mainstream_category)
    tag = Whitehall.content_api.tag(mainstream_category.parent_tag) || {}
    {
      title: mainstream_category.title,
      id: mainstream_category.path,
      web_url: nil,
      details: {
        type: 'section'
      },
      content_with_tag: {
        id: mainstream_category.path,
        web_url: url_maker.mainstream_category_path(mainstream_category)
      },
      parent: tag.to_hash
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
      web_url: url_maker.mainstream_category_path(@mainstream_category),
      id: @mainstream_category.path,
      tags: [Whitehall.content_api.tag(@mainstream_category.parent_tag).to_hash]
    }
  end
end
