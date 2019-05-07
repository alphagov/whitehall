require 'test_helper'

class PublishingApiPresentersTest < ActiveSupport::TestCase
  test ".presenter_for returns a presenter for a case study" do
    case_study = CaseStudy.new
    presenter = PublishingApiPresenters.presenter_for(case_study)

    assert_equal PublishingApi::CaseStudyPresenter, presenter.class
  end

  test ".presenter_for returns a presenter for a detailed guide" do
    detailed_guide = DetailedGuide.new
    presenter = PublishingApiPresenters.presenter_for(detailed_guide)

    assert_equal PublishingApi::DetailedGuidePresenter, presenter.class
  end

  test ".presenter_for returns a presenter for a Take Part page" do
    take_part_page = TakePartPage.new
    presenter = PublishingApiPresenters.presenter_for(take_part_page)

    assert_equal PublishingApi::TakePartPresenter, presenter.class
  end

  test ".presenter_for returns a presenter for a Statistics Announcement" do
    statistics_announcement = StatisticsAnnouncement.new
    presenter = PublishingApiPresenters.presenter_for(statistics_announcement)

    assert_equal PublishingApi::StatisticsAnnouncementPresenter, presenter.class
  end

  test ".presenter_for returns a Speech Presenter for the Speech model" do
    assert_equal PublishingApi::SpeechPresenter,
                 PublishingApiPresenters.presenter_for(Speech.new).class
  end

  test ".presenter_for returns a Generic Edition presenter for all models without a presenter class" do
    assert_equal PublishingApi::GenericEditionPresenter,
                 PublishingApiPresenters.presenter_for(GenericEdition.new).class
  end

  test ".presenter_for returns a Placeholder presenter for an organisation" do
    organisation = Organisation.new
    presenter = PublishingApiPresenters.presenter_for(organisation)

    assert_equal PublishingApi::OrganisationPresenter, presenter.class
  end

  test ".presenter_for returns a Person presenter for a person" do
    person = Person.new
    presenter = PublishingApiPresenters.presenter_for(person)

    assert_equal PublishingApi::PersonPresenter, presenter.class
  end

  test ".presenter_for returns a Role presenter for a role" do
    role = Role.new
    presenter = PublishingApiPresenters.presenter_for(role)

    assert_equal PublishingApi::RolePresenter, presenter.class
  end

  test ".presenter_for returns a RoleAppointment presenter for a role appointment" do
    role_appointment = RoleAppointment.new
    presenter = PublishingApiPresenters.presenter_for(role_appointment)

    assert_equal PublishingApi::RoleAppointmentPresenter, presenter.class
  end

  test ".presenter_for returns a WorldLocation presenter for a world location" do
    ministerial_role = WorldLocation.new
    presenter = PublishingApiPresenters.presenter_for(ministerial_role)

    assert_equal PublishingApi::WorldLocationPresenter, presenter.class
  end

  test ".presenter_for returns a WorldwideOrganisation presenter for a worldwide organisation" do
    worldwide_organisation = WorldwideOrganisation.new
    presenter = PublishingApiPresenters.presenter_for(worldwide_organisation)

    assert_equal PublishingApi::WorldwideOrganisationPresenter, presenter.class
  end

  test ".presenter_for returns a WorkingGroup presenter for a policy group" do
    policy_group = PolicyGroup.new
    presenter = PublishingApiPresenters.presenter_for(policy_group)

    assert_equal PublishingApi::WorkingGroupPresenter, presenter.class
  end

  test ".presenter_for returns TopicalEvent placeholder for a TopicalEvent" do
    presenter = PublishingApiPresenters.presenter_for(TopicalEvent.new)
    assert_equal PublishingApi::TopicalEventPresenter, presenter.class
  end

  test ".presenter_for returns a special-case presenter for `Topic`" do
    presenter = PublishingApiPresenters.presenter_for(Topic.new)
    assert_equal PublishingApi::PolicyAreaPlaceholderPresenter, presenter.class
  end

  test ".presenter_for returns a HtmlAttachment presenter for `HtmlAttachment`" do
    presenter = PublishingApiPresenters.presenter_for(build(:html_attachment))
    assert_equal PublishingApi::HtmlAttachmentPresenter, presenter.class
  end

  test ".presenter_for returns a DocumentCollection presenter for `DocumentCollection`" do
    presenter = PublishingApiPresenters.presenter_for(build(:document_collection))
    assert_equal PublishingApi::DocumentCollectionPresenter, presenter.class
  end

  test ".presenter_for returns an OperationalFieldPresenter for an OperationalField" do
    presenter = PublishingApiPresenters.presenter_for(build(:operational_field))
    assert_equal PublishingApi::OperationalFieldPresenter, presenter.class
  end

  test ".presenter_for returns a FatalityNoticePresenter for a FatalityNotice" do
    presenter = PublishingApiPresenters.presenter_for(build(:fatality_notice))
    assert_equal PublishingApi::FatalityNoticePresenter, presenter.class
  end

  test ".presenter_for returns a StatisticalDataSetPresenter for a StatisticalDataSet" do
    presenter = PublishingApiPresenters.presenter_for(build(:statistical_data_set))
    assert_equal PublishingApi::StatisticalDataSetPresenter, presenter.class
  end

  test ".presenter_for returns a ConsultationPresenter for a Consultation" do
    presenter = PublishingApiPresenters.presenter_for(build(:consultation))
    assert_equal PublishingApi::ConsultationPresenter, presenter.class
  end

  test ".presenter_for returns a WorldLocationNewsArticlePresenter for a WorldLocationNewsArticle" do
    presenter = PublishingApiPresenters.presenter_for(build(:world_location_news_article))
    assert_equal PublishingApi::WorldLocationNewsArticlePresenter, presenter.class
  end

  test ".presenter_for returns a NewsArticlePresenter for a NewsArticle" do
    presenter = PublishingApiPresenters.presenter_for(build(:news_article))
    assert_equal PublishingApi::NewsArticlePresenter, presenter.class
  end

  test ".presenter_for returns a CorporateInformationPagePresenter for a " +
    "CorporateInformationPage belonging to an Organisation" do
    presenter = PublishingApiPresenters
      .presenter_for(
        build(
          :corporate_information_page,
          organisation: build(:organisation),
        ),
      )

    assert_equal(
      PublishingApi::CorporateInformationPagePresenter,
      presenter.class,
    )
  end

  test ".presenter_for returns a GenericEditionPresenter for a " +
    "CorporateInformationPage belonging to an WorldwideOrganisation" do
    presenter = PublishingApiPresenters
      .presenter_for(
        build(
          :corporate_information_page,
          worldwide_organisation: build(:worldwide_organisation),
        ),
      )

    assert_equal(
      PublishingApi::GenericEditionPresenter,
      presenter.class,
    )
  end
end
