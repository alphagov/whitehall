require 'test_helper'
require 'gds_api/test_helpers/content_store'

class DataHygiene::PublishingApiSyncCheckTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  test "checks that the format published in the content store matches the persisted model" do
    create(
      :take_part_page,
      title: "Title of a take part page",
      slug: "take-part-slug",
    )
    payload = {
      format: "take_part",
      title: "Title of a take part page",
      base_path: "/government/get-involved/take-part/take-part-slug",
    }
    content_store_has_item("/government/get-involved/take-part/take-part-slug", payload)

    check = check_take_part
    check.perform(output: false)

    assert_equal(["/government/get-involved/take-part/take-part-slug"], check.successes)
    assert_empty(check.failures)
  end

  test "detects when the format published in the Content Store does not match the persisted model" do
    create(
      :take_part_page,
      title: "Title of a take part page",
      slug: "take-part-slug",
    )
    payload = {
      format: "placeholder", # unexpected format in Content Store
      title: "Title of a take part page",
      base_path: "/government/get-involved/take-part/take-part-slug",
    }
    content_store_has_item("/government/get-involved/take-part/take-part-slug", payload)

    check = check_take_part
    check.perform(output: false)

    assert_empty(check.successes)
    assert_equal(["/government/get-involved/take-part/take-part-slug"], check.failures)
  end

  test "detects when the content item is missing from the Content Store" do
    create(
      :take_part_page,
      title: "Title of a take part page",
      slug: "take-part-slug",
    )
    content_store_does_not_have_item("/government/get-involved/take-part/take-part-slug")

    check = check_take_part
    check.perform(output: false)

    assert_empty(check.successes)
    assert_equal(["/government/get-involved/take-part/take-part-slug"], check.failures)
  end

  test "overriding the base path fetching for formats that don't follow the conventions" do
    event = create(:topical_event, slug: 'example-event')
    create(:about_page, topical_event: event, name: "About page")

    payload = {
      format: "topical_event_about_page",
      title: "About page",
      base_path: "/government/topical-events/example-event/about",
    }
    content_store_has_item("/government/topical-events/example-event/about", payload)

    check = check_about_pages
    check.override_base_path(&:search_link)
    check.perform(output: false)

    assert_equal(["/government/topical-events/example-event/about"], check.successes)
    assert_empty(check.failures)
  end

  def check_take_part
    check = DataHygiene::PublishingApiSyncCheck.new(TakePartPage.all)

    check.add_expectation do |content_store_payload, _|
      content_store_payload["format"] == 'take_part'
    end
    check.add_expectation do |content_store_payload, model|
      content_store_payload["base_path"] == Whitehall.url_maker.polymorphic_path(model)
    end
    check.add_expectation do |content_store_payload, model|
      content_store_payload["title"] == model.title
    end

    check
  end

  def check_about_pages
    check = DataHygiene::PublishingApiSyncCheck.new(AboutPage.all)

    check.add_expectation do |content_store_payload, _|
      content_store_payload["format"] == 'topical_event_about_page'
    end
    check.add_expectation do |content_store_payload, model|
      content_store_payload["base_path"] == model.search_link
    end
    check.add_expectation do |content_store_payload, model|
      content_store_payload["title"] == model.name
    end

    check
  end
end
