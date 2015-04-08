require 'publishing_api_presenters/edition.rb'
require 'publishing_api_presenters/case_study.rb'
require 'publishing_api_presenters/coming_soon.rb'
require 'publishing_api_presenters/placeholder.rb'
require 'publishing_api_presenters/unpublishing.rb'

module PublishingApiPresenters
  def self.presenter_for(model, options={})
    presenter_class_for(model).new(model, options)
  end

private
  def self.presenter_class_for(model)
    if model.is_a?(::Edition)
      presenter_class_for_edition(model)
    elsif model.is_a?(::Unpublishing)
      PublishingApiPresenters::Unpublishing
    else
      PublishingApiPresenters::Placeholder
    end
  end

  def self.presenter_class_for_edition(edition)
    if edition.is_a?(::CaseStudy)
      PublishingApiPresenters::CaseStudy
    else
      PublishingApiPresenters::Edition
    end
  end
end
