require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_show_related_policies_and_topics_for :publication
  should_show_the_countries_associated_with :publication
  should_display_inline_images_for :publication
  should_not_display_lead_image_for :publication
  should_show_change_notes :publication

  test 'show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.document
    assert_response :success
  end

  test "show displays inapplicable nations" do
    published_publication = create(:published_publication)
    northern_ireland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_publication.document

    assert_select inapplicable_nations_selector do
      assert_select "p", "This publication does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "show should not explicitly say that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.document

    refute_select inapplicable_nations_selector
  end

  test "show should display publication metadata" do
    publication = create(:published_publication,
      publication_date: Date.parse("1916-05-31"),
      unique_reference: "unique-reference",
      isbn: "0099532816",
      order_url: "http://example.com/order-path",
      publication_type_id: PublicationType::Form.id,
      price_in_pence: 999
    )

    get :show, id: publication.document

    assert_select ".contextual-info" do
      assert_select ".publication_type", text: "Form"
      assert_select ".publication_date", text: "31 May 1916"
      assert_select ".unique_reference", text: "unique-reference"
      assert_select ".isbn", text: "0099532816"
      assert_select "a.order_url[href='http://example.com/order-path']"
      assert_select ".price", text: "&pound;9.99"
    end
  end

  test "show should not mention the unique reference if there isn't one" do
    publication = create(:published_publication, unique_reference: '')

    get :show, id: publication.document

    assert_select ".contextual-info" do
      refute_select ".unique_reference"
    end
  end

  test "show should not mention the ISBN if there isn't one" do
    publication = create(:published_publication, isbn: '')

    get :show, id: publication.document

    assert_select ".contextual-info" do
      refute_select ".isbn"
    end
  end

  test "show should not display an order link if no order url exists" do
    publication = create(:published_publication, order_url: nil)

    get :show, id: publication.document

    assert_select ".body" do
      refute_select "a.order_url"
    end
  end

  test "should not display the price if there's an order url but the publication is free" do
    publication = create(:published_publication, order_url: 'http://example.com', price_in_pence: nil)

    get :show, id: publication.document

    assert_select ".contextual-info" do
      refute_select ".price"
    end
  end

  test "show should display a National Statistic badge on the appropriate documents" do
    publication = create(:published_publication, publication_type_id: PublicationType::NationalStatistics.id)
    get :show, id: publication.document

    assert_match /National Statistic/, response.body
  end

  test "index only displays published publications" do
    archived_publication = create(:archived_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    get :index

    assert_select_object(published_publication)
    refute_select_object(archived_publication)
    refute_select_object(draft_publication)
  end

  test 'index should not use n+1 selects' do
    10.times { create(:published_publication) }
    assert 10 > count_queries { get :index }
  end

  test "index displays the featured publication that was published most recently" do
    older_featured_publication = create(:featured_publication, publication_date: 2.days.ago)
    newer_featured_publication = create(:featured_publication, publication_date: 1.day.ago)

    get :index

    assert_select "#{record_css_selector(newer_featured_publication)}.featured"
    refute_select "#{record_css_selector(older_featured_publication)}.featured"
  end

  test "index can be filtered by the topic of the associated policy" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1]

    assert_select_object @published_publication
    refute_select_object @published_in_second_topic
  end

  test "index can be filtered by the union of multiple topics" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select_object @published_publication
    assert_select_object @published_in_second_topic
  end

  test "index only lists topics with associated published editions" do
    given_two_publications_in_two_topics
    another_topic = create(:topic, policies: [create(:draft_policy)])

    get :index

    refute assigns[:all_topics].include?(another_topic)
  end

  test "index lists topic filter options in alphabetical order" do
    topic_1 = create(:topic, name: "Yak shaving")
    topic_2 = create(:topic, name: "Aardvark protection")
    create_publications_in(topic_1, topic_2)

    get :index

    assert_equal ["Aardvark protection", "Yak shaving"], assigns[:all_topics].map(&:name)
  end

  test "index highlights selected topic filter options" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: @topic_1.name
      assert_select "option[selected='selected']", text: @topic_2.name
    end
  end

  test "index highlights all topics filter option by default" do
    given_two_publications_in_two_topics

    get :index

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  test 'index should not use n+1 selects when filtering by topics' do
    policy = create(:published_policy)
    topic = create(:topic, policies: [policy])
    10.times { create(:published_publication, related_policies: [policy]) }
    assert 10 > count_queries { get :index, topics: [topic] }
  end

  test "index should show a helpful message if there are no matching publications" do
    topic = create(:topic)
    get :index, topics: [topic]

    assert_select "p", text: "There are no matching publications."
  end

  private

  def given_two_publications_in_two_topics
    @topic_1, @topic_2 = create(:topic), create(:topic)
    @published_publication, @published_in_second_topic = create_publications_in(@topic_1, @topic_2)
  end

  def create_publications_in(*topics)
    topics.map do |topic|
      policy = create(:published_policy)
      topic.policies << policy
      publication = create(:published_publication, related_policies: [policy])
      topic.update_counts
      publication
    end
  end

  def assert_featured(doc)
    assert_select "#{record_css_selector(doc)}.featured"
  end
end
