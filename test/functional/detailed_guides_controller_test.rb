require "test_helper"
require "gds_api/test_helpers/content_store"

class DetailedGuidesControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentStore

  should_be_a_public_facing_controller
  should_display_attachments_for :detailed_guide
  should_show_inapplicable_nations :detailed_guide
  should_be_previewable :detailed_guide
  should_set_slimmer_analytics_headers_for :detailed_guide
  should_set_the_article_id_for_the_edition_for :detailed_guide
  should_not_show_share_links_for :detailed_guide

  view_test "guide <title> contains Detailed guidance" do
    guide = create(:published_detailed_guide)

    get :show, id: guide.document

    assert_select "title", text: /${guide.document.title} | Detailed guidance/
  end

  view_test "shows related organisations" do
    organisation = create(:organisation, name: 'The Organisation')
    guide = create(:published_detailed_guide, organisations: [organisation])

    get :show, id: guide.document

    assert_select "a[href=?]", organisation_path(organisation), text: 'The Organisation'
  end

  view_test "shows link to each section in the document navigation" do
    guide = create(:published_detailed_guide, body: %{
## First Section

Some content

## Another Bit

More content

## Final Part

That's all
})

    get :show, id: guide.document

    assert_select "ol#document_sections" do
      assert_select "li a[href='#first-section']", 'First Section'
      assert_select "li a[href='#another-bit']", 'Another Bit'
      assert_select "li a[href='#final-part']", 'Final Part'
    end
  end

  view_test "show includes any links to related mainstream content" do
    content_store_has_item("/content", title: "Some related mainstream content")
    content_store_has_item("/additional-content", title: "Some additional related mainstream content")

    lookup_hash = {
      "/content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
      "/additional-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312"
    }

    publishing_api_has_lookups(lookup_hash)

    guide = create(:published_detailed_guide,
      related_mainstream_content_url: "https://www.gov.uk/content",
      related_mainstream_content_title: "A title that will be ignored",
      additional_related_mainstream_content_url: "https://www.gov.uk/additional-content",
      additional_related_mainstream_content_title: "Another title that will be ignored"
    )

    get :show, id: guide.document

    assert_select "a[href='https://www.gov.uk/content']", "Some related mainstream content"
    assert_select "a[href='https://www.gov.uk/additional-content']", "Some additional related mainstream content"
  end

  test "the format name is being set to 'detailed_guidance'" do
    guide = create(:published_detailed_guide)

    get :show, id: guide.document

    assert_equal "detailed_guidance", response.headers["X-Slimmer-Format"]
  end

  private

  def given_two_detailed_guides_in_two_organisations
    @organisation_1, @organisation_2 = create(:organisation), create(:organisation)
    @detailed_guide_in_organisation_1 = create(:published_detailed_guide, organisations: [@organisation_1])
    @detailed_guide_in_organisation_2 = create(:published_detailed_guide, organisations: [@organisation_2])
  end

  def given_two_detailed_guides_in_two_topics
    @topic_1, @topic_2 = create(:topic), create(:topic)
    @published_detailed_guide, @published_in_second_topic = create_detailed_guides_in(@topic_1, @topic_2)
  end

  def create_detailed_guides_in(*topics)
    topics.map do |topic|
      create(:published_detailed_guide, topics: [topic])
    end
  end
end
