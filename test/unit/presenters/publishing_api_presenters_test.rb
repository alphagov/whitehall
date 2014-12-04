require 'test_helper'

class PublishingApiPresentersTest < ActiveSupport::TestCase
  test ".presenter_for returns a presenter for a case study" do
    case_study = CaseStudy.new
    presenter  = PublishingApiPresenters.presenter_for(case_study)

    assert_equal PublishingApiPresenters::CaseStudy, presenter.class
    assert_equal case_study, presenter.edition
  end

  test ".presenter_for returns an unpublishing presenter for an unpublished case study" do
    case_study = create(:draft_case_study)
    unpublishing = create(:unpublishing, edition: case_study)
    presenter = PublishingApiPresenters.presenter_for(case_study)

    assert_equal PublishingApiPresenters::Unpublishing, presenter.class
  end

  test ".presenter_for returns a redirect presenter when unpublishing is set to redirect automatically" do
    case_study = create(:draft_case_study)
    unpublishing = create(:unpublishing, edition: case_study, redirect: true, alternative_url: "#{Whitehall.public_root}/foobar")
    presenter = PublishingApiPresenters.presenter_for(case_study)

    assert_equal PublishingApiPresenters::Redirect, presenter.class
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
    assert_equal organisation, presenter.item
  end

  test ".presenter_for returns a Placeholder presenter for a world location" do
    world_location = WorldLocation.new
    presenter  = PublishingApiPresenters.presenter_for(world_location)

    assert_equal PublishingApiPresenters::Placeholder, presenter.class
    assert_equal world_location, presenter.item
  end
end
