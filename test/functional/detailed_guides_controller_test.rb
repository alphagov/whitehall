require "test_helper"

class DetailedGuidesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :detailed_guide
  should_show_inapplicable_nations :detailed_guide
  should_be_previewable :detailed_guide

  view_test "show doesn't include header-context element which is used for breadcrumbs" do
    guide = create(:published_detailed_guide)

    get :show, id: guide.document

    refute_select ".header-context"
  end

  view_test "guide <title> contains Detailed guidance" do
    guide = create(:published_detailed_guide)

    get :show, id: guide.document

    assert_select "title", text: /${guide.document.title} | Detailed guidance/
  end

  view_test "shows related organisations" do
    organisation = create(:organisation, name: 'The Organisation')
    guide = create(:published_detailed_guide, organisations: [organisation])

    get :show, id: guide.document

    assert_select_object organisation do
      assert_select "a[href=#{organisation_path(organisation)}]", text: 'The Organisation'
    end
  end

  test "show sets search action to search detailed guides" do
    get :show, id: create(:published_detailed_guide).document
    assert_equal 'detailed', response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER]
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
    guide = create(:published_detailed_guide,
      related_mainstream_content_url: "http://mainstream/content",
      related_mainstream_content_title: "Some related mainstream content",
      additional_related_mainstream_content_url: "http://mainstream/additional-content",
      additional_related_mainstream_content_title: "Some additional related mainstream content"
    )

    get :show, id: guide.document

    assert_select "a[href='http://mainstream/content']", "Some related mainstream content"
    assert_select "a[href='http://mainstream/additional-content']", "Some additional related mainstream content"
  end

  view_test "show indicates when a guide replaced businesslink content" do
    guide = create(:published_detailed_guide, replaces_businesslink: true)

    get :show, id: guide.document

    assert_select ".replaces-businesslink"
  end

  view_test "show mainstream categories for a detailed guide" do
    category = create(:mainstream_category)
    guide = create(:published_detailed_guide, primary_mainstream_category: category)
    get :show, id: guide.document

    assert_select_object category
  end

  view_test "show sets breadcrumb trail" do
    category = create(:mainstream_category)
    detailed_guide = create(:published_detailed_guide, primary_mainstream_category: category)

    get :show, id: detailed_guide.document

    artefact_headers = ActiveSupport::JSON.decode(response.headers[Slimmer::Headers::ARTEFACT_HEADER])

    assert_equal category.title, artefact_headers['tags'].first['title']
  end

  view_test "show includes link to API representation" do
    detailed_guide = create(:published_detailed_guide)

    get :show, id: detailed_guide.document

    assert_select "link[rel=alternate][href=?]", api_detailed_guide_url(detailed_guide.document)
  end

  test "the format name is being set to 'detailed_guidance'" do
    guide = create(:published_detailed_guide)

    get :show, id: guide.document

    assert_equal "detailed_guidance", response.headers["X-Slimmer-Format"]
  end

  view_test "guides have their mainstream categories added as classes" do
    category = create(:mainstream_category)
    guide = create(:published_detailed_guide, primary_mainstream_category: category)
    get :show, id: guide.document

    assert_select ".category-#{category.slug}"
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
