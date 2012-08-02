require "test_helper"

class SpecialistGuidesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_display_attachments_for :specialist_guide
  should_show_inapplicable_nations :specialist_guide
  should_paginate :specialist_guide, sort_by: :title
  should_return_json_suitable_for_the_document_filter :specialist_guide

  test "index <title> does not contain 'Inside Government'" do
    get :index

    refute_select "title", text: /Inside Government/
  end

  test "index sets search action to search specialist guides" do
    get :index
    assert_equal search_specialist_guides_path, response.headers[Slimmer::SEARCH_PATH_HEADER]
  end

  test "guide <title> contains Specialist guidance" do
    guide = create(:published_specialist_guide)

    get :show, id: guide.document

    assert_select "title", text: /${guide.document.title} | Specialist guidance/
  end

  test "organisation links are to their external site" do
    organisation = create(:organisation, url: 'http://google.com', logo_formatted_name: 'The Organisation')
    guide = create(:published_specialist_guide, organisations: [organisation])

    get :show, id: guide.document

    assert_select_object organisation do
      assert_select 'a[rel=external][href=http://google.com]', text: 'The Organisation'
    end
  end

  test "show sets search action to search specialist guides" do
    get :show, id: create(:published_specialist_guide).document
    assert_equal search_specialist_guides_path, response.headers[Slimmer::SEARCH_PATH_HEADER]
  end

  test "shows link to each section in the document navigation" do
    guide = create(:published_specialist_guide, body: %{
## First Section

Some content

## Another Bit

More content

## Final Part

That's all
})

    get :show, id: guide.document

    assert_select "ol#document_sections" do
      assert_select "li a[href='#{public_document_path(guide, anchor: 'first-section')}']", 'First Section'
      assert_select "li a[href='#{public_document_path(guide, anchor: 'another-bit')}']", 'Another Bit'
      assert_select "li a[href='#{public_document_path(guide, anchor: 'final-part')}']", 'Final Part'
    end
  end

  test "shows link to subsections in the document navigation" do
    guide = create(:published_specialist_guide, body: %{
## First Section

Some Content

### Sub section title

some more content
})

    get :show, id: guide.document

    assert_select "ol#document_sections" do
      assert_select "li ol li a[href='#{public_document_path(guide, anchor: 'sub-section-title')}']", 'Sub section title'
    end
  end

  test "show includes any links to related mainstream content" do
    guide = create(:published_specialist_guide,
      related_mainstream_content_url: "http://mainstream/content",
      related_mainstream_content_title: "Some related mainstream content"
    )

    get :show, id: guide.document

    assert_select "a[href='http://mainstream/content']", "Some related mainstream content"
  end

  test "adds pagination behaviour to paginated guide" do
    edition = create(:published_specialist_guide, paginate_body: true)
    get :show, id: edition.document

    assert_select ".document_page.js-paginate-document"
  end

  test "doesn't add pagination behaviour to non-paginated guide" do
    edition = create(:published_specialist_guide, paginate_body: false)
    get :show, id: edition.document

    assert_select ".document_page.js-paginate-document", count: 0
  end

  test "index highlights selected topic filter options" do
    given_two_specialist_guides_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: @topic_1.name
      assert_select "option[selected='selected']", text: @topic_2.name
    end
  end

  test "index highlights selected organisation filter options" do
    given_two_specialist_guides_in_two_organisations

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
    given_two_specialist_guides_in_two_topics

    get :index

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  test "index highlights all organisations filter options by default" do
    given_two_specialist_guides_in_two_organisations

    get :index

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: "All departments"
    end
  end

  test "index shows filter keywords placeholder by default" do
    get :index

    assert_select "input[name='keywords'][placeholder=?]", "keywords"
  end

  test "index should show a helpful message if there are no matching specialist guides" do
    get :index

    assert_select "h2", text: "There are no matching specialist guides."
  end

  test "index requested as JSON includes the specialist guides" do
    org = create(:organisation, name: "org-name")
    org2 = create(:organisation, name: "other-org")
    topic = create(:topic, name: "topic-name")
    other_topic = create(:topic, name: "other-topic")
    guide = create(:published_specialist_guide, title: "guide-title", organisations: [org, org2], topics: [topic, other_topic])

    get :index, format: :json

    results = ActiveSupport::JSON.decode(response.body)["results"]
    assert_equal 1, results.length
    guide_json = results.first
    assert_equal "specialist_guide", guide_json["type"]
    assert_equal "guide-title", guide_json["title"]
    assert_equal guide.id, guide_json["id"]
    assert_equal specialist_guide_path(guide.document), guide_json["url"]
    assert_equal "topic-name<br>other-topic", guide_json["topics"]
    assert_equal "org-name and other-org", guide_json["organisations"]
  end

  test "search sets search path header to search specialist guides" do
    search_client = stub('search_client')
    Whitehall.search_client.stubs(:search).returns([])
    get :search
    assert_equal search_specialist_guides_path, response.headers[Slimmer::SEARCH_PATH_HEADER]
  end

  test "search lists each result returned from the inside government client" do
    Whitehall.mainstream_search_client.stubs(:search).returns([])
    Whitehall.search_client.stubs(:search).with('query', 'specialist_guidance').returns([{"title" => "title", "link" => "/specialist/guide-slug", "highlight" => "", "format" => "specialist_guidance"}])
    get :search, q: 'query'
    assert_select ".specialist_guidance a[href='/specialist/guide-slug']"
  end

  test "search lists 3 results returned from the mainstream search" do
    Whitehall.search_client.stubs(:search).returns([])
    Whitehall.mainstream_search_client.stubs(:search).with('query').returns([
      {"title" => "a", "link" => "/a", "highlight" => "", "format" => "planner"},
      {"title" => "b", "link" => "/b", "highlight" => "", "format" => "planner"},
      {"title" => "c", "link" => "/c", "highlight" => "", "format" => "planner"},
      {"title" => "d", "link" => "/d", "highlight" => "", "format" => "planner"}
    ])
    get :search, q: 'query'

    assert_select ".planner a[href='/a']"
    assert_select ".planner a[href='/b']"
    assert_select ".planner a[href='/c']"
    assert_select ".planner a[href='/d']", count: 0
  end

  test "search shows the description if available" do
    Whitehall.search_client.stubs(:search).returns([
      {"title" => "a", "link" => "/a", "description" => "description-text",
       "highlight" => "highlight-text", "format" => "specialist_guide"}
    ])
    Whitehall.mainstream_search_client.stubs(:search).returns([])
    get :search, q: 'query'

    assert_select ".search-results .specialist_guide .description", "description-text"
    assert_select ".search-results .specialist_guide .highlight", false
  end

  test "search shows the highlight if no description available" do
    Whitehall.search_client.stubs(:search).returns([
      {"title" => "a", "link" => "/a", "description" => "",
       "highlight" => "highlight-text", "format" => "specialist_guide"}
    ])
    Whitehall.mainstream_search_client.stubs(:search).returns([])
    get :search, q: 'query'

    assert_select ".search-results .specialist_guide .description", false
    assert_select ".search-results .specialist_guide .highlight", "&hellip;highlight-text&hellip;"
  end

  test "search links to mainstream browse sections for mainstream results" do
    Whitehall.search_client.stubs(:search).returns([])
    Whitehall.mainstream_search_client.stubs(:search).returns([
      {"title" => "a", "link" => "/a", "description" => "blah",
       "highlight" => "", "section" => "money-and-tax", "format" => "thing"}
    ])
    get :search, q: 'query'

    assert_select ".search-results .thing .section a[href='/browse/money-and-tax']", "Money and tax"
  end

  test "autocomplete returns the response from autocomplete as a string" do
    search_client = stub('search_client')
    raw_rummager_response = "rummager-response-body-json"
    Whitehall.search_client.stubs(:autocomplete).with("search-term", "specialist_guidance").returns(raw_rummager_response)
    get :autocomplete, q: "search-term"
    assert_equal raw_rummager_response, @response.body
  end

  private

  def given_two_specialist_guides_in_two_organisations
    @organisation_1, @organisation_2 = create(:organisation), create(:organisation)
    @specialist_guide_in_organisation_1 = create(:published_specialist_guide, organisations: [@organisation_1])
    @specialist_guide_in_organisation_2 = create(:published_specialist_guide, organisations: [@organisation_2])
  end

  def given_two_specialist_guides_in_two_topics
    @topic_1, @topic_2 = create(:topic), create(:topic)
    @published_specialist_guide, @published_in_second_topic = create_specialist_guides_in(@topic_1, @topic_2)
  end

  def create_specialist_guides_in(*topics)
    topics.map do |topic|
      create(:published_specialist_guide, topics: [topic])
    end
  end
end
