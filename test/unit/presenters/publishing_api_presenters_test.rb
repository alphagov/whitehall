require 'test_helper'

class PublishingApiPresentersTest < ActiveSupport::TestCase
  test ".presenter_for returns a presenter for a case study" do
    case_study = CaseStudy.new
    presenter  = PublishingApiPresenters.presenter_for(case_study)

    assert_equal PublishingApiPresenters::CaseStudy, presenter.class
  end

  test ".presenter_for returns a presenter for a Take Part page" do
    take_part_page = TakePartPage.new
    presenter = PublishingApiPresenters.presenter_for(take_part_page)

    assert_equal PublishingApiPresenters::TakePart, presenter.class
  end

  test ".presenter_for returns a presenter for a Statistics Announcement" do
    statistics_announcement = StatisticsAnnouncement.new
    presenter = PublishingApiPresenters.presenter_for(statistics_announcement)

    assert_equal PublishingApiPresenters::StatisticsAnnouncement, presenter.class
  end

  test ".presenter_for returns a redirect presenter for a
    Statistics Announcement that requires a redirect" do
    statistics_announcement = build(:statistics_announcement_requiring_redirect)

    presenter = PublishingApiPresenters.presenter_for(statistics_announcement)

    assert_equal PublishingApiPresenters::StatisticsAnnouncementRedirect, presenter.class
  end

  test ".presenter_for returns an Unpublishing presenter for an Unpublishing" do
    unpublishing = Unpublishing.new
    presenter = PublishingApiPresenters.presenter_for(unpublishing)

    assert_equal PublishingApiPresenters::Unpublishing, presenter.class
  end

  test ".presenter_for returns a generic Edition presenter for non-case studies" do
    assert_equal PublishingApiPresenters::Edition,
      PublishingApiPresenters.presenter_for(GenericEdition.new).class

    assert_equal PublishingApiPresenters::Edition,
      PublishingApiPresenters.presenter_for(NewsArticle.new).class
  end

  test ".presenter_for returns a Placeholder presenter for an organisation" do
    organisation = Organisation.new
    presenter  = PublishingApiPresenters.presenter_for(organisation)

    assert_equal PublishingApiPresenters::Organisation, presenter.class
  end

  test ".presenter_for returns a Placeholder presenter for a world location" do
    world_location = WorldLocation.new
    presenter  = PublishingApiPresenters.presenter_for(world_location)

    assert_equal PublishingApiPresenters::Placeholder, presenter.class
  end

  test ".presenter_for returns a WorkingGroup presenter for a policy group" do
    policy_group = PolicyGroup.new
    presenter = PublishingApiPresenters.presenter_for(policy_group)

    assert_equal PublishingApiPresenters::WorkingGroup, presenter.class
  end

  test ".presenter_for returns TopicalEvent placeholder for a TopicalEvent" do
    presenter = PublishingApiPresenters.presenter_for(TopicalEvent.new)
    assert_equal PublishingApiPresenters::TopicalEvent, presenter.class
  end

  test ".presenter_for returns a special-case presenter for `Topic`" do
    presenter = PublishingApiPresenters.presenter_for(Topic.new)
    assert_equal PublishingApiPresenters::PolicyAreaPlaceholder, presenter.class
  end
end
