module PublishingApiPresenters
  def self.presenter_for(model, options={})
    presenter_class_for(model).new(model, options)
  end

  class UndefinedPresenterError < StandardError
  end

private
  def self.presenter_class_for(model)
    case model
    when ::Edition
      presenter_class_for_edition(model)
    when AboutPage
      PublishingApi::TopicalEventAboutPagePresenter
    when PolicyGroup
      PublishingApi::WorkingGroupPresenter
    when TakePartPage
      PublishingApi::TakePartPresenter
    when Topic
      PublishingApi::PolicyAreaPlaceholderPresenter
    when ::Organisation
      PublishingApi::OrganisationPresenter
    when ::TopicalEvent
      PublishingApi::TopicalEventPresenter
    when ::StatisticsAnnouncement
      PublishingApi::StatisticsAnnouncementPresenter
    when ::HtmlAttachment
      PublishingApi::HtmlAttachmentPresenter
    when ::Person
      PublishingApi::PersonPresenter
    when ::WorldLocation
      PublishingApi::WorldLocationPresenter
    when ::MinisterialRole
      PublishingApi::MinisterialRolePresenter
    when ::WorldwideOrganisation
      PublishingApi::WorldwideOrganisationPresenter
    when ::Contact
      PublishingApi::ContactPresenter
    when OperationalField
      PublishingApi::OperationalFieldPresenter
    else
      raise UndefinedPresenterError, "Could not find presenter class for: #{model.inspect}"
    end
  end

  def self.presenter_class_for_edition(edition)
    case edition
    when ::CaseStudy
      PublishingApi::CaseStudyPresenter
    when Consultation
      PublishingApi::ConsultationPresenter
    when ::DocumentCollection
      PublishingApi::DocumentCollectionPresenter
    when ::DetailedGuide
      PublishingApi::DetailedGuidePresenter
    when ::FatalityNotice
      PublishingApi::FatalityNoticePresenter
    when ::NewsArticle
      PublishingApi::NewsArticlePresenter
    when ::Publication
      PublishingApi::PublicationPresenter
    when ::Speech
      PublishingApi::SpeechPresenter
    when StatisticalDataSet
      PublishingApi::StatisticalDataSetPresenter
    when WorldLocationNewsArticle
      PublishingApi::WorldLocationNewsArticlePresenter
    else
      # This is a catch-all clause for the following classes:
      # - CorporateInformationPage
      # The presenter implementation for all of these models is identical and
      # the structure of the presented payload is the same.
      PublishingApi::GenericEditionPresenter
    end
  end
end
