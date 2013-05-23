require 'test_helper'

class WorldLocationNewsArticlePresenterTest < ActionView::TestCase

  setup do
    setup_view_context
  end

  test "lead_image_path returns the world wide organisation default image" do
    image = create(:default_news_organisation_image_data)
    worldwide_organisation = create(:worldwide_organisation, default_news_image: image)
    world_location_news_article = create(:world_location_news_article, worldwide_organisations: [worldwide_organisation])
    presenter = WorldLocationNewsArticlePresenter.new(world_location_news_article, @view_context)
    assert_match worldwide_organisation.default_news_image.file.url(:s300), presenter.lead_image_path
  end

  test '#sorted_organisations returns decorted worldwide organisations in alphabetical order' do
    world_org1 = create(:worldwide_organisation, name: 'Ministry of Jazz')
    world_org2 = create(:worldwide_organisation, name: 'Free Jazz Foundation')
    world_org3 = create(:worldwide_organisation, name: 'Jazz Bizniz')
    edition = create(:world_location_news_article, worldwide_organisations: [world_org3, world_org1, world_org2])

    sorted_decorated_orgs = [world_org2, world_org3, world_org1].collect {|wo| WorldwideOrganisationPresenter.new(wo) }

    assert_equal sorted_decorated_orgs, WorldLocationNewsArticlePresenter.new(edition, 'context stub').sorted_organisations
  end
end
