require "test_helper"

class PublishingApi::EditionableWorldwideOrganisationPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::EditionableWorldwideOrganisationPresenter.new(...)
  end

  test "presents a Worldwide Organisation ready for adding to the publishing API" do
    worldwide_org = create(:editionable_worldwide_organisation)

    public_path = worldwide_org.public_path

    expected_hash = {
      base_path: public_path,
      title: worldwide_org.title,
      schema_name: "worldwide_organisation",
      document_type: "editionable_worldwide_organisation",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {
        logo: {
          crest: "single-identity",
        },
      },
      update_type: "major",
    }

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    # TODO: uncomment the below assertion when the editionable_worldwide_organisation model is
    # finished and all content can be added to this presenter.
    # assert_valid_against_publisher_schema(presented_item.content, "worldwide_organisation")
  end
end
