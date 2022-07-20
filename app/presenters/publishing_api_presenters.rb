module PublishingApiPresenters
  UndefinedPresenterError = Class.new(StandardError)

  class << self
    def presenter_for(model, options = {})
      presenter_class_for(model).new(model, **options)
    end

  private

    FALLBACK_EDITION_PRESENTER = PublishingApi::GenericEditionPresenter

    def presenter_class_for(model)
      case model
      when ::Edition
        presenter_class_for_edition(model)
      when Government
        PublishingApi::GovernmentPresenter
      when TopicalEventAboutPage
        PublishingApi::TopicalEventAboutPagePresenter
      when PolicyGroup
        PublishingApi::WorkingGroupPresenter
      when TakePartPage
        PublishingApi::TakePartPresenter
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
      when ::Role
        PublishingApi::RolePresenter
      when ::RoleAppointment
        PublishingApi::RoleAppointmentPresenter
      when ::WorldLocation
        PublishingApi::WorldLocationPresenter
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

    def presenter_class_for_edition(edition)
      case edition
      when ::CaseStudy
        PublishingApi::CaseStudyPresenter
      when Consultation
        PublishingApi::ConsultationPresenter
      when CorporateInformationPage
        if edition.worldwide_organisation.present?
          FALLBACK_EDITION_PRESENTER
        else
          PublishingApi::CorporateInformationPagePresenter
        end
      when ::DetailedGuide
        PublishingApi::DetailedGuidePresenter
      when ::DocumentCollection
        PublishingApi::DocumentCollectionPresenter
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
      else
        # The presenter implementation for all of these models is identical and
        # the structure of the presented payload is the same.
        FALLBACK_EDITION_PRESENTER
      end
    end
  end
end
