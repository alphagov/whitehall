require 'publishing_api_presenters/edition'
require 'publishing_api_presenters/case_study'
require 'publishing_api_presenters/coming_soon'
require 'publishing_api_presenters/placeholder'
require 'publishing_api_presenters/unpublishing'
require 'publishing_api_presenters/redirect'

module PublishingApiPresenters
  def self.presenter_for(model, options={})
    presenter_class_for(model).new(model, options)
  end

private
  def self.presenter_class_for(model)
    case model
    when ::Edition
      presenter_class_for_edition(model)
    when ::Unpublishing
      PublishingApiPresenters::Unpublishing
    when PolicyGroup
      PublishingApiPresenters::WorkingGroup
    when TakePartPage
      PublishingApiPresenters::TakePart
    else
      PublishingApiPresenters::Placeholder
    end
  end

  def self.presenter_class_for_edition(edition)
    case edition
    when ::CaseStudy
      PublishingApiPresenters::CaseStudy
    else
      PublishingApiPresenters::Edition
    end
  end
end
