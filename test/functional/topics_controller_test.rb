require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  include AtomTestHelpers

  should_be_a_public_facing_controller

  view_test "GET :index lists topics with published policies" do
    topics = [0, 1, 2].map { |n| create(:topic, published_policies_count: n) }
    get :index

    refute_select_object(topics[0])
    assert_select_object(topics[1])
    assert_select_object(topics[2])
  end

  view_test "GET :shows lists the topic details, setting the expiry headers based on the scheduled editions" do
    organisation = create(:organisation)
    policy = create(:draft_policy, :scheduled)
    topic = create(:topic, organisations: [organisation], editions: [policy, create(:published_news_article)])

    controller.expects(:expire_on_next_scheduled_publication).with(topic.scheduled_editions)

    get :show, id: topic

    assert_select "h1", text: topic.name
    assert_select ".govspeak", text: topic.description
    assert_equal topic.description, assigns(:meta_description)
    assert_select_object organisation
  end

  view_test "GET :show lists the published policies and their summaries" do
    published_policy = create(:published_policy, title: "policy-title", summary: "policy-summary")
    topic = create(:topic, policies: [published_policy])

    get :show, id: topic

    assert_select "#policies" do
      assert_select_object(published_policy) do
        assert_select "h2", text: "policy-title"
        assert_select ".summary", text: /policy-summary/
      end
    end
  end

  view_test "GET :show lists published publications and links to more" do
    topic = create(:topic)
    published = []
    4.times do |i|
      published << create(:published_publication, {
        title: "title-#{i}", topics: [topic], first_published_at: i.days.ago
      })
    end

    get :show, id: topic

    assert_select "#publications" do
      published.take(3).each do |edition|
        assert_select_object(edition) do
          assert_select "h2", text: edition.title
        end
      end
      refute_select_object(published[3])
    end
  end

  view_test "GET :show lists published announcements and links to more" do
    topic = create(:topic)
    published = []
    4.times do |i|
      published << create(:published_news_article, {
        title: "title-#{i}", topics: [topic], first_published_at: i.days.ago
      })
    end

    get :show, id: topic

    assert_select "#announcements" do
      published.take(3).each do |edition|
        assert_select_object(edition) do
          assert_select "h2", text: edition.title
        end
      end
      refute_select_object(published[3])
    end
  end

  view_test "GET :show lists 5 published detailed guides and links to more" do
    published_detailed_guides = []
    6.times do |i|
      published_detailed_guides << create(:published_detailed_guide, title: "detailed-guide-title-#{i}")
    end
    topic = create(:topic, detailed_guides: published_detailed_guides)

    get :show, id: topic

    assert_select ".detailed-guidance" do
      published_detailed_guides.take(5).each do |guide|
        assert_select_object(guide) do
          assert_select "h2", text: guide.title
        end
      end
      refute_select_object(published_detailed_guides[5])
    end
  end

  view_test "GET :show displays latest documents relating to the topic, including atom feed and govdelivery links" do
    topic = create(:topic)
    policy_1 = create(:published_policy, topics: [topic])
    news_article = create(:published_news_article, topics: [topic])
    policy_2 = create(:published_policy, topics: [topic])
    create(:classification_featuring, classification: topic, edition: policy_1)

    get :show, id: topic

    assert_select "#recently-updated" do
      assert_select_prefix_object policy_1, prefix="recent"
      assert_select_prefix_object policy_2, prefix="recent"
      assert_select_prefix_object news_article, prefix="recent"
    end
    assert_select ".govdelivery[href='#{email_signups_path(topic: topic.slug)}']"
    assert_select_autodiscovery_link topic_url(topic, format: 'atom')
  end

  view_test 'GET :show for atom feed has the right elements' do
    topic = build(:topic, id: 1)
    policy = create(:published_policy)
    topic.stubs(:latest).returns([policy])
    Topic.stubs(:find).returns(topic)

    get :show, id: topic, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', topic_url(topic, format: 'atom'), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', topic_url(topic), 1

      assert_select_atom_entries([policy])
    end
  end

  test 'GET :show has a 5 minute expiry time' do
    topic = build(:topic)
    Topic.stubs(:find).returns(topic)

    get :show, id: topic

    assert_cache_control("max-age=#{5.minutes}")
  end

  test 'GET :show caps max expiry to 5 minute when there are future scheduled editions' do
    topic = create(:topic)
    create(:scheduled_publication, scheduled_publication: 1.day.from_now, topics: [topic])

    get :show, id: topic

    assert_cache_control("max-age=#{5.minutes}")
  end
end
