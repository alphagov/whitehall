require "test_helper"

class PublishingApi::TopicalEventAboutPagePresenterTest < ActiveSupport::TestCase
  def present(record)
    PublishingApi::TopicalEventAboutPagePresenter.new(record)
  end

  test "topical event about page presentation includes the correct values" do
    topical_event_about_page = create(:topical_event_about_page)

    expected_hash = {
      base_path: topical_event_about_page.search_link,
      title: topical_event_about_page.name,
      description: "Summary",
      schema_name: "topical_event_about_page",
      document_type: "topical_event_about_page",
      locale: "en",
      public_updated_at: topical_event_about_page.updated_at,
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "government-frontend",
      routes: [
        { path: topical_event_about_page.search_link, type: "exact" },
      ],
      redirects: [],
      update_type: "major",
      details: {
        body: "<div class=\"govspeak\"><p>Body</p></div>",
        read_more: "Read more",
      },
    }

    presented_item = present(topical_event_about_page)
    presented_content = presented_item.content

    assert_valid_against_publisher_schema(presented_item.content, "topical_event_about_page")
    assert_valid_against_links_schema({ links: presented_item.links }, "topical_event_about_page")
    assert_equal topical_event_about_page.topical_event.content_id, presented_item.links[:parent][0]

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
                           presented_content[:details].delete(:body)

    assert_equal expected_hash, presented_content
  end

  test "it includes headers when headers are present in body" do
    topical_event_about_page = create(
      :topical_event_about_page,
      body: "##Some header\n\nSome content",
    )

    presented_topical_event_about_page = PublishingApi::TopicalEventAboutPagePresenter.new(topical_event_about_page)

    expected_headers = [
      {
        text: "Some header",
        level: 2,
        id: "some-header",
      },
    ]

    assert_equal expected_headers, presented_topical_event_about_page.content[:details][:headers]
  end

  test "it does not include headers when headers are not present in body" do
    topical_event_about_page = create(
      :topical_event_about_page,
      body: "Some content",
    )

    presented_topical_event_about_page = PublishingApi::TopicalEventAboutPagePresenter.new(topical_event_about_page)

    assert_nil presented_topical_event_about_page.content[:details][:headers]
  end
end
