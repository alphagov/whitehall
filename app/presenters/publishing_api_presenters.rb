require 'publishing_api_presenters/edition.rb'
require 'publishing_api_presenters/case_study.rb'
require 'publishing_api_presenters/placeholder.rb'

module PublishingApiPresenters
  def self.presenter_for(model, options={})
    presenter_class_for(model).new(model, options)
  end

  def self.presenter_class_for(model)
    if model.is_a?(::Edition)
      presenter_class_for_edition(model)
    else
      PublishingApiPresenters::Placeholder
    end
  end

  def self.presenter_class_for_edition(edition)
    if !edition.publicly_visible? && edition.unpublishing.present?
      if edition.unpublishing.redirect?
        PublishingApiPresenters::EditionRedirect
      else
        PublishingApiPresenters::Unpublishing
      end
    elsif edition.is_a?(::CaseStudy)
      PublishingApiPresenters::CaseStudy
    else
      PublishingApiPresenters::Edition
    end
  end

end
