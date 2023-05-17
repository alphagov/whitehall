require "test_helper"

class PublishingApi::WorldwideOfficePresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::WorldwideOfficePresenter.new(...)
  end

  test "presents a Worldwide Office ready for adding to the publishing API" do
    access_and_opening_times = "## About us\r\n\r\nVisit our [profile page](https://www.gov.uk/government/world/organisations/british-consulate-general-atlanta)"
    worldwide_office = create(:worldwide_office, access_and_opening_times:)
    public_path = worldwide_office.public_path

    expected_hash = {
      base_path: public_path,
      title: worldwide_office.worldwide_organisation.name,
      schema_name: "worldwide_office",
      document_type: "worldwide_office",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "whitehall-frontend",
      public_updated_at: worldwide_office.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {
        access_and_opening_times: Whitehall::GovspeakRenderer.new.govspeak_to_html(worldwide_office.access_and_opening_times),
      },
      update_type: "major",
    }

    expected_links = {
      contact: [
        worldwide_office.contact.content_id,
      ],
      parent: [
        worldwide_office.worldwide_organisation.content_id,
      ],
    }

    presented_item = present(worldwide_office)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_office.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "worldwide_office")
    assert_valid_against_links_schema({ links: presented_item.links }, "worldwide_office")
  end
end
