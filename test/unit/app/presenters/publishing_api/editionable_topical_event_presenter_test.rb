require "test_helper"

class PublishingApi::EditionableTopicalEventPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::EditionableTopicalEventPresenter.new(...)
  end

  test "presents a Topical Event ready for adding to the publishing API" do
    topical_event = create(:editionable_topical_event)

    public_path = topical_event.public_path

    expected_hash = {
      base_path: public_path,
      title: topical_event.title,
      schema_name: "topical_event",
      document_type: "editionable_topical_event",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      public_updated_at: topical_event.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {},
      update_type: "major",
    }

    expected_links = {}

    presented_item = present(topical_event)

    assert_equal expected_hash, presented_item.content
    assert_equal "major", presented_item.update_type
    assert_equal topical_event.content_id, presented_item.content_id

    # TODO: uncomment the below assertion when the editionable_topical_event model is
    # finished and all content can be added to this presenter.
    # assert_valid_against_publisher_schema(presented_item.content, "topical_event")

    assert_equal expected_links, presented_item.links
    assert_valid_against_links_schema({ links: presented_item.links }, "topical_event")
  end
end
