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
    when AboutPage
      PublishingApiPresenters::TopicalEventAboutPage
    when PolicyGroup
      PublishingApiPresenters::WorkingGroup
    when TakePartPage
      PublishingApiPresenters::TakePart
    when Topic
      PublishingApiPresenters::PolicyAreaPlaceholder
    when ::TopicalEvent
      PublishingApiPresenters::TopicalEvent
    when ::StatisticsAnnouncement
      PublishingApiPresenters::StatisticsAnnouncement
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
