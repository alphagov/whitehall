require 'publishing_api_presenters/edition.rb'
require 'publishing_api_presenters/case_study.rb'
require 'publishing_api_presenters/placeholder.rb'
require 'publishing_api_presenters/unpublishing.rb'

module PublishingApiPresenters
  def self.presenter_for(model, options={})
    presenter_class_for(model).new(model, options)
  end

  def self.publish_intent_for(model)
    PublishingApiPresenters::PublishIntent.new(model)
  end

  def self.coming_soon_for(model)
    PublishingApiPresenters::ComingSoon.new(model)
  end

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
