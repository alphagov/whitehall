require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_show_related_policies_and_policy_topics_for :publication
  should_show_the_countries_associated_with :publication
  should_display_inline_images_for :publication
  should_not_display_lead_image_for :publication
  should_show_change_notes :publication

  test "should only display published publications" do
    archived_publication = create(:archived_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    get :index

    assert_select_object(published_publication)
    refute_select_object(archived_publication)
    refute_select_object(draft_publication)
  end

  test 'show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.doc_identity
    assert_response :success
  end

  test 'should avoid n+1 selects when showing index' do
    10.times { create(:published_publication) }
    assert 10 > count_queries { get :index }
  end

  test "should show inapplicable nations" do
    published_publication = create(:published_publication)
    northern_ireland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_publication.doc_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This publication does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should not explicitly say that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.doc_identity

    refute_select inapplicable_nations_selector
  end

  test "should display publication metadata" do
    publication = create(:published_publication,
      publication_date: Date.parse("1916-05-31"),
      unique_reference: "unique-reference",
      isbn: "0099532816",
      research: true,
      order_url: "http://example.com/order-path"
    )

    get :show, id: publication.doc_identity

    assert_select ".contextual_info" do
      assert_select ".publication_date", text: "31 May 1916"
      assert_select ".unique_reference", text: "unique-reference"
      assert_select ".isbn", text: "0099532816"
      assert_select ".research", text: "This is a research paper."
      assert_select "a.order_url[href='http://example.com/order-path']"
    end
  end

  test "should not mention the unique reference if there isn't one" do
    publication = create(:published_publication, unique_reference: '')

    get :show, id: publication.doc_identity

    assert_select ".contextual_info" do
      refute_select ".unique_reference"
    end
  end

  test "should not mention the ISBN if there isn't one" do
    publication = create(:published_publication, isbn: '')

    get :show, id: publication.doc_identity

    assert_select ".contextual_info" do
      refute_select ".isbn"
    end
  end

  test "should not display an order link if no order url exists" do
    publication = create(:published_publication, order_url: nil)

    get :show, id: publication.doc_identity

    assert_select ".body" do
      refute_select "a.order_url"
    end
  end

  def assert_featured(doc)
    assert_select "#{record_css_selector(doc)}.featured"
  end

  test "index displays the featured publication that was published most recently" do
    older_featured_publication = create(:featured_publication, publication_date: 2.days.ago)
    newer_featured_publication = create(:featured_publication, publication_date: 1.day.ago)

    get :index

    assert_select "#{record_css_selector(newer_featured_publication)}.featured"
    refute_select "#{record_css_selector(older_featured_publication)}.featured"
  end

  def given_two_publications_in_two_policy_topics
    @policy_1 = create(:published_policy)
    @policy_topic_1 = create(:policy_topic, policies: [@policy_1])
    @policy_2 = create(:published_policy)
    @policy_topic_2 = create(:policy_topic, policies: [@policy_2])
    @published_publication = create(:published_publication, related_policies: [@policy_1])
    @published_in_second_policy_topic = create(:published_publication, related_policies: [@policy_2])
  end

  test "can filter by the policy topic of the associated policy" do
    given_two_publications_in_two_policy_topics

    get :by_policy_topic, policy_topics: @policy_topic_1.slug

    assert_select_object @published_publication
    refute_select_object @published_in_second_policy_topic
  end

  test "can filter by the union of multiple policy topics" do
    given_two_publications_in_two_policy_topics

    get :by_policy_topic, policy_topics: @policy_topic_1.slug + "+" + @policy_topic_2.slug

    assert_select_object @published_publication
    assert_select_object @published_in_second_policy_topic
  end

  test 'should avoid n+1 selects when filtering by policy topics' do
    policy = create(:published_policy)
    policy_topic = create(:policy_topic, policies: [policy])
    10.times { create(:published_publication, related_policies: [policy]) }
    assert 10 > count_queries { get :by_policy_topic, policy_topics: policy_topic }
  end

  test "should show a helpful message if there are no matching publications" do
    policy_topic = create(:policy_topic)
    get :by_policy_topic, policy_topics: policy_topic.slug

    assert_select "p", text: "There are no matching publications."
  end
end
