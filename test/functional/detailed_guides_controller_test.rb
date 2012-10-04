require "test_helper"

class DetailedGuidesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_display_attachments_for :detailed_guide
  should_show_inapplicable_nations :detailed_guide
  should_paginate :detailed_guide, sort_by: :title
  should_be_previewable :detailed_guide
  should_return_json_suitable_for_the_document_filter :detailed_guide

  test "index <title> does not contain 'Inside Government'" do
    get :index

    refute_select "title", text: /Inside Government/
  end

  test "index sets search index to search detailed guides" do
    get :index
    assert_equal 'detailed', response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER]
  end

  test "guide <title> contains Detailed guidance" do
    guide = create(:published_detailed_guide)

    get :show, id: guide.document

    assert_select "title", text: /${guide.document.title} | Detailed guidance/
  end

  test "organisation links are to their external site" do
    organisation = create(:organisation, url: 'http://google.com', logo_formatted_name: 'The Organisation')
    guide = create(:published_detailed_guide, organisations: [organisation])

    get :show, id: guide.document

    assert_select_object organisation do
      assert_select 'a[rel=external][href=http://google.com]', text: 'The Organisation'
    end
  end

  test "show sets search action to search detailed guides" do
    get :show, id: create(:published_detailed_guide).document
    assert_equal 'detailed', response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER]
  end

  test "shows link to each section in the document navigation" do
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

  test "show includes any links to related mainstream content" do
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

  test "show indicates when a guide replaced businesslink content" do
    guide = create(:published_detailed_guide, replaces_businesslink: true)

    get :show, id: guide.document

    assert_select ".replaces-businesslink"
  end

  test "index highlights selected topic filter options" do
    given_two_detailed_guides_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: @topic_1.name
      assert_select "option[selected='selected']", text: @topic_2.name
    end
  end

  test "index highlights selected organisation filter options" do
    given_two_detailed_guides_in_two_organisations

    get :index, departments: [@organisation_1, @organisation_2]

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: @organisation_1.name
      assert_select "option[selected='selected']", text: @organisation_2.name
    end
  end

  test "index displays filter keywords" do
    get :index, keywords: "olympics 2012"

    assert_select "input[name='keywords'][value=?]", "olympics 2012"
  end

  test "index highlights all topics filter option by default" do
    given_two_detailed_guides_in_two_topics

    get :index

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  test "index highlights all organisations filter options by default" do
    given_two_detailed_guides_in_two_organisations

    get :index

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: "All departments"
    end
  end

  test "index shows filter keywords placeholder by default" do
    get :index

    assert_select "input[name='keywords'][placeholder=?]", "keywords"
  end

  test "index should show a helpful message if there are no matching detailed guides" do
    get :index

    assert_select "h2", text: "There are no matching detailed guides."
  end

  test "index requested as JSON includes the detailed guides" do
    org = create(:organisation, name: "org-name")
    org2 = create(:organisation, name: "other-org")
    topic = create(:topic, name: "topic-name")
    other_topic = create(:topic, name: "other-topic")
    guide = create(:published_detailed_guide, title: "guide-title", organisations: [org, org2], topics: [topic, other_topic])

    get :index, format: :json

    results = ActiveSupport::JSON.decode(response.body)["results"]
    assert_equal 1, results.length
    guide_json = results.first
    assert_equal "detailed_guide", guide_json["type"]
    assert_equal "guide-title", guide_json["title"]
    assert_equal guide.id, guide_json["id"]
    assert_equal detailed_guide_path(guide.document), guide_json["url"]
    assert_equal "topic-name, other-topic", guide_json["topics"]
    assert_equal "org-name and other-org", guide_json["organisations"]
  end

  test "show mainstream categories for a detailed guide" do
    category = create(:mainstream_category)
    guide = create(:published_detailed_guide, primary_mainstream_category: category)
    get :show, id: guide.document

    assert_select_object category
  end

  test "show sets breadcrumb trail" do
    category = create(:mainstream_category)
    detailed_guide = create(:published_detailed_guide, primary_mainstream_category: category)

    get :show, id: detailed_guide.document

    artefact_headers = ActiveSupport::JSON.decode(response.headers[Slimmer::Headers::ARTEFACT_HEADER])

    assert_equal category.title, artefact_headers['tags'].first['title']
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
