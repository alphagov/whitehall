require "test_helper"
require "rake"

class RedirectInternationalDelegationRakeTest < ActiveSupport::TestCase
  setup do
    Rake::Task["temp_redirect_international_delegation"].reenable
  end

  test "it should redirect an international delegation" do
    world_location_news = build(:world_location_news)
    create(:international_delegation, :with_worldwide_organisations, world_location_news:, slug: "uk-delegation")

    Services.publishing_api.expects(:unpublish)
      .with(
        world_location_news.content_id,
        type: "redirect",
        locale: "en",
        alternative_path: "/world/uk-delegation",
      )
      .once

    Rake.application.invoke_task("temp_redirect_international_delegation")
  end

  test "it should never redirect a world location" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:, slug: "mock-country")

    Services.publishing_api.expects(:unpublish)
      .with(
        world_location_news.content_id,
        type: "redirect",
        locale: "en",
        alternative_path: "/world/mock-country",
      )
      .never

    Rake.application.invoke_task("temp_redirect_international_delegation")
  end
end
