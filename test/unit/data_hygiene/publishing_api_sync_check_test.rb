require 'test_helper'
require 'gds_api/test_helpers/content_store'
require 'data_hygiene/publishing_api_sync_check'

class DataHygiene::PublishingApiSyncCheckTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore
  setup do
    @progress = stub("ProgressBar", log: nil, increment: nil, finish: nil)
    ProgressBar.stubs(create: @progress)
  end

  test "checks that the format published in the Content Store and the Draft Content Store matches the persisted model" do
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
    content_store_has_item("/government/get-involved/take-part/take-part-slug", payload, draft: true)

    check = check_take_part
    assert_output(/Successes: 2\nFailures: 0/m) do
      check.perform
    end

    assert_equal ["/government/get-involved/take-part/take-part-slug"] * 2, check.successes.map(&:base_path)
    assert_empty(check.failures)
  end

  test "checker works with editions" do
    create(:published_case_study, title: 'Example case study')
    payload = {
      format: "case_study",
      base_path: "/government/case-studies/example-case-study",
    }
    content_store_has_item("/government/case-studies/example-case-study", payload)
    content_store_has_item("/government/case-studies/example-case-study", payload, draft: true)

    check = check_case_study
    assert_output(/Successes: 1\nFailures: 0/m) do
      check.perform
    end

    assert_equal ["/government/case-studies/example-case-study"], check.successes.map(&:base_path)
    assert_empty(check.failures)
  end

  test "checker works with translated versions of editions" do
    create(:published_case_study, :translated, translated_into: [:fr], title: 'Example case study')

    payload = {
      format: "case_study",
      base_path: "/government/case-studies/example-case-study",
    }

    translated_payload = {
      format: "case_study",
      base_path: "/government/case-studies/example-case-study.fr",
    }

    content_store_has_item("/government/case-studies/example-case-study", payload)
    content_store_has_item("/government/case-studies/example-case-study.fr", translated_payload)
    content_store_has_item("/government/case-studies/example-case-study", payload, draft: true)
    content_store_has_item("/government/case-studies/example-case-study", translated_payload, draft: true)

    check = check_case_study
    assert_output(/Successes: 1\nFailures: 0/m) do
      check.perform
    end

    assert_equal ["/government/case-studies/example-case-study"], check.successes.map(&:base_path)
    assert_empty check.failures
  end

  test "detects missing translations of editions" do
    create(:published_case_study, :translated, translated_into: [:es], title: 'Another example case study')

    payload = {
      format: "case_study",
      base_path: "/government/case-studies/another-example-case-study",
    }

    translated_payload = {
      format: "case_study",
      base_path: "/government/case-studies/another-example-case-study.es",
    }

    content_store_has_item("/government/case-studies/another-example-case-study", payload)
    content_store_has_item("/government/case-studies/another-example-case-study", payload, draft: true)
    content_store_has_item("/government/case-studies/another-example-case-study.es", translated_payload, draft: true)

    content_store_does_not_have_item("/government/case-studies/another-example-case-study.es")

    check = check_case_study
    assert_output(/Successes: 0\nFailures: 1/m) do
      check.perform
    end

    assert_empty check.successes
    assert_equal ["/government/case-studies/another-example-case-study"], check.failures.map(&:base_path)
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
    content_store_has_item("/government/get-involved/take-part/take-part-slug", payload, draft: true)

    check = check_take_part
    assert_output(/Successes: 0\nFailures: 2/m) do
      check.perform
    end

    assert_empty(check.successes)
    assert_equal(
      [
        check_failure(
          base_path: "/government/get-involved/take-part/take-part-slug",
          failed_expectations: %w[format],
        )
      ] * 2,
      check.failures
    )
  end

  test "detects when the content item is missing from the Content Store" do
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

    content_store_does_not_have_item("/government/get-involved/take-part/take-part-slug")
    content_store_has_item("/government/get-involved/take-part/take-part-slug", payload, draft: true)

    check = check_take_part
    check.perform(output: false)

    assert_equal(1, check.successes.count)
    assert_equal(
      [
        check_failure(
          base_path: "/government/get-involved/take-part/take-part-slug",
          failed_expectations: ["unreachable: "],
        )
      ],
      check.failures
    )
  end

  test "detects when the content item is missing from the Draft Content Store" do
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
    content_store_does_not_have_item("/government/get-involved/take-part/take-part-slug", draft: true)

    check = check_take_part
    check.perform(output: false)

    assert_equal(1, check.successes.count)
    assert_equal(
      [
        check_failure(
          base_path: "/government/get-involved/take-part/take-part-slug",
          failed_expectations: ["unreachable: "],
        )
      ],
      check.failures
    )
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
    content_store_has_item("/government/topical-events/example-event/about", payload, draft: true)

    check = check_about_pages
    check.override_base_path(&:search_link)
    check.perform(output: false)

    assert_equal ["/government/topical-events/example-event/about", "/government/topical-events/example-event/about"], check.successes.map(&:base_path)
    assert_empty(check.failures)
  end

  def check_take_part
    check = DataHygiene::PublishingApiSyncCheck.new(TakePartPage.all)

    check.add_expectation("format") do |content_store_payload, _|
      content_store_payload["format"] == 'take_part'
    end
    check.add_expectation("base_path") do |content_store_payload, model|
      content_store_payload["base_path"] == Whitehall.url_maker.polymorphic_path(model)
    end
    check.add_expectation("title") do |content_store_payload, model|
      content_store_payload["title"] == model.title
    end

    check
  end

  def check_about_pages
    check = DataHygiene::PublishingApiSyncCheck.new(AboutPage.all)

    check.add_expectation("format") do |content_store_payload, _|
      content_store_payload["format"] == 'topical_event_about_page'
    end
    check.add_expectation("base_path") do |content_store_payload, model|
      content_store_payload["base_path"] == model.search_link
    end
    check.add_expectation("title") do |content_store_payload, model|
      content_store_payload["title"] == model.name
    end

    check
  end

  def check_case_study
    check = DataHygiene::PublishingApiSyncCheck.new(CaseStudy.latest_published_edition)

    check.add_expectation("format") do |content_store_payload, _|
      content_store_payload["format"] == 'case_study'
    end

    check
  end

  def check_failure(base_path:, failed_expectations:, content_store: "content-store")
    DataHygiene::PublishingApiSyncCheck::Failure.new(
      record_id: 1,
      base_path: base_path,
      failed_expectations: failed_expectations,
      content_store: content_store
    )
  end
end
