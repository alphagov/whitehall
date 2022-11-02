require "test_helper"
require "rake"

class PublishFindersRakeTest < ActiveSupport::TestCase
  setup do
    Rake::Task["finders:temp_unpublish_non_english_finders"].reenable
  end

  test "it publishes then marks as gone each non-English finder" do
    Locale.stubs(:non_english).returns([
      Locale.new(:cy),
      Locale.new(:fr),
    ])

    Services.publishing_api.expects(:put_content).with("88936763-df8a-441f-8b96-9ea0dc0758a1", has_entries(
                                                                                                 base_path: "/government/announcements.cy",
                                                                                                 locale: "cy",
                                                                                               ))
    Services.publishing_api.expects(:publish).with("88936763-df8a-441f-8b96-9ea0dc0758a1", nil, locale: :cy)
    Whitehall::PublishingApi.expects(:publish_gone_async).with("88936763-df8a-441f-8b96-9ea0dc0758a1", nil, nil, "cy")

    Services.publishing_api.expects(:put_content).with("88936763-df8a-441f-8b96-9ea0dc0758a1", has_entries(
                                                                                                 base_path: "/government/announcements.fr",
                                                                                                 locale: "fr",
                                                                                               ))
    Services.publishing_api.expects(:publish).with("88936763-df8a-441f-8b96-9ea0dc0758a1", nil, locale: :fr)
    Whitehall::PublishingApi.expects(:publish_gone_async).with("88936763-df8a-441f-8b96-9ea0dc0758a1", nil, nil, "fr")

    Services.publishing_api.expects(:put_content).with("b13317e9-3753-47b2-95da-c173071e621d", has_entries(
                                                                                                 base_path: "/government/publications.cy",
                                                                                                 locale: "cy",
                                                                                               ))
    Services.publishing_api.expects(:publish).with("b13317e9-3753-47b2-95da-c173071e621d", nil, locale: :cy)
    Whitehall::PublishingApi.expects(:publish_gone_async).with("b13317e9-3753-47b2-95da-c173071e621d", nil, nil, "cy")

    Services.publishing_api.expects(:put_content).with("b13317e9-3753-47b2-95da-c173071e621d", has_entries(
                                                                                                 base_path: "/government/publications.fr",
                                                                                                 locale: "fr",
                                                                                               ))
    Services.publishing_api.expects(:publish).with("b13317e9-3753-47b2-95da-c173071e621d", nil, locale: :fr)
    Whitehall::PublishingApi.expects(:publish_gone_async).with("b13317e9-3753-47b2-95da-c173071e621d", nil, nil, "fr")

    Rake.application.invoke_task "finders:temp_unpublish_non_english_finders"
  end

  test "it does not unpublish the English finder" do
    Services.publishing_api.expects(:put_content).with("88936763-df8a-441f-8b96-9ea0dc0758a1", has_entries(
                                                                                                 base_path: "/government/announcements",
                                                                                                 locale: "en",
                                                                                               )).never
    Services.publishing_api.expects(:publish).with("88936763-df8a-441f-8b96-9ea0dc0758a1", nil, locale: :en).never
    Whitehall::PublishingApi.expects(:publish_gone_async).with("88936763-df8a-441f-8b96-9ea0dc0758a1", nil, nil, "en").never

    Services.publishing_api.expects(:put_content).with("b13317e9-3753-47b2-95da-c173071e621d", has_entries(
                                                                                                 base_path: "/government/publications",
                                                                                                 locale: "en",
                                                                                               )).never
    Services.publishing_api.expects(:publish).with("b13317e9-3753-47b2-95da-c173071e621d", nil, locale: :en).never
    Whitehall::PublishingApi.expects(:publish_gone_async).with("b13317e9-3753-47b2-95da-c173071e621d", nil, nil, "en").never

    Services.publishing_api.expects(:put_content).at_least_once
    Services.publishing_api.expects(:publish).at_least_once
    Whitehall::PublishingApi.expects(:publish_gone_async).at_least_once

    Rake.application.invoke_task "finders:temp_unpublish_non_english_finders"
  end
end
