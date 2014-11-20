require 'publishing_api_presenters/edition.rb'
require 'publishing_api_presenters/case_study.rb'
require 'publishing_api_presenters/organisation.rb'

module PublishingApiPresenters
  def self.presenter_for(model)
    presenter_class_for(model).new(model)
  end

  def self.presenter_class_for(model)
    if model.is_a?(::CaseStudy)
      PublishingApiPresenters::CaseStudy
    elsif model.is_a?(::Organisation)
      PublishingApiPresenters::Organisation
    else
      PublishingApiPresenters::Edition
    end
  end
end
