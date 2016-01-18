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

  test ".presenter_for returns an Unpublishing presenter for an Unpublishing" do
    unpublishing = create(:unpublishing)
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

    assert_equal PublishingApiPresenters::Placeholder, presenter.class
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
end
