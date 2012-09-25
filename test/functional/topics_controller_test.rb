require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper

  should_be_a_public_facing_controller

  test "shows topic title and description" do
    topic = create(:topic)
    get :show, id: topic
    assert_select ".topic", text: topic.name
    assert_select ".document", text: topic.description
  end

  test "shows published policies and their summaries" do
    published_policy = create(:published_policy, title: "policy-title", summary: "policy-summary")
    topic = create(:topic, policies: [published_policy])

    get :show, id: topic

    assert_select "#policies" do
      assert_select_object(published_policy) do
        assert_select "h2", text: "policy-title"
        assert_select ".summary", text: /policy-summary/
      end
    end
    assert_select "a[href=?]", "#policies"
  end

  test "shows 5 published detailed guides and links to more" do
    published_detailed_guides = []
    6.times do |i|
      published_detailed_guides << create(:published_detailed_guide, title: "detailed-guide-title-#{i}")
    end
    topic = create(:topic, detailed_guides: published_detailed_guides)

    get :show, id: topic

    assert_select "#detailed-guidance" do
      published_detailed_guides.take(5).each do |guide|
        assert_select_object(guide) do
          assert_select "li", text: guide.title
        end
      end
      refute_select_object(published_detailed_guides[5])
      assert_select "a[href=#{detailed_guides_path("topics[]" => topic.slug)}]"
    end
    assert_select "a[href=?]", "#detailed-guidance"
  end

  test "doesn't show unpublished policies" do
    draft_policy = create(:draft_policy)
    topic = create(:topic, policies: [draft_policy])

    get :show, id: topic

    refute_select_object(draft_policy)
  end

  test "doesn't show unpublished detailed guides" do
    draft_detailed_guide = create(:draft_detailed_guide)
    topic = create(:topic, detailed_guides: [draft_detailed_guide])

    get :show, id: topic

    refute_select_object(draft_detailed_guide)
  end

  test "should not display an empty detailed guides section" do
    topic = create(:topic)
    get :show, id: topic
    refute_select "#detailed-guides"
    refute_select "a[href=?]", "#detailed-guidance"
  end

  test "should not display an empty published policies section" do
    topic = create(:topic)
    get :show, id: topic
    refute_select "#policies"
    refute_select "a[href=?]", "#policies"
  end

  test "show displays links to related topics" do
    related_topic_1 = create(:topic)
    related_topic_2 = create(:topic)
    unrelated_topic = create(:topic)
    topic = create(:topic, related_topics: [related_topic_1, related_topic_2])

    get :show, id: topic

    assert_select "#related-topics" do
      assert_select_object related_topic_1 do
        assert_select "a[href='#{topic_path(related_topic_1)}']"
      end
      assert_select_object related_topic_2 do
        assert_select "a[href='#{topic_path(related_topic_2)}']"
      end
      assert_select_object unrelated_topic, count: 0
    end
    assert_select "a[href=?]", "#related-topics"
  end

  test "show does not display empty related topics section" do
    topic = create(:topic, related_topics: [])

    get :show, id: topic

    assert_select "#related-topics ul", count: 0
    refute_select "a[href=?]", "#related-topics"
  end

  test "show displays recently changed documents relating to policies in the topic" do
    policy_1 = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy_1])
    news_article = create(:published_news_article, related_policies: [policy_1])

    policy_2 = create(:published_policy)
    speech = create(:published_speech, related_policies: [policy_2])

    topic = create(:topic, policies: [policy_1, policy_2])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object policy_1
      assert_select_object policy_2
      assert_select_object news_article
      assert_select_object publication
      assert_select_object speech
    end
    assert_select "a[href=?]", "#recently-changed"
  end

  test "show displays a maximum of 5 recently changed documents" do
    policy = create(:published_policy)
    6.times { create(:published_news_article, related_policies: [policy]) }
    topic = create(:topic, policies: [policy])

    get :show, id: topic

    assert_select "#recently-changed tbody tr", count: 5
  end

  test "show does not display empty recently changed section" do
    topic = create(:topic)
    get :show, id: topic
    refute_select "#recently-changed ul"
    refute_select "a[href=?]", "#recently-changed"
  end

  test "show displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    policy = create(:published_policy)
    speech = create(:published_speech, published_at: published_at, related_policies: [policy])

    topic = create(:topic, policies: [policy])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select '.type', text: "Speech"
        assert_select ".published-at[title='#{published_at.iso8601}']"
      end
    end
  end

  test "show displays recently changed documents including the policy in order of the edition's publication date with most recent first" do
    policy_1 = create(:published_policy, published_at: 2.weeks.ago)
    publication_1 = create(:published_publication, published_at: 6.weeks.ago, related_policies: [policy_1])
    news_article_1 = create(:published_news_article, published_at: 1.week.ago, related_policies: [policy_1])

    policy_2 = create(:published_policy, published_at: 5.weeks.ago)
    news_article_2 = create(:published_news_article, published_at: 4.weeks.ago, related_policies: [policy_2])
    publication_2 = create(:published_publication, published_at: 3.weeks.ago, related_policies: [policy_2])

    topic = create(:topic, policies: [policy_1, policy_2])

    get :show, id: topic

    expected = [news_article_1, policy_1, publication_2, news_article_2, policy_2, publication_1]
    actual = assigns(:recently_changed_documents)
    assert_equal expected, actual
  end

  test "show distinguishes between published and updated documents" do
    first_edition = create(:published_policy)
    updated_edition = create(:published_policy, published_at: Time.zone.now, first_published_at: 1.day.ago)

    topic = create(:topic, policies: [first_edition, updated_edition])

    get :show, id: topic

    assert_select_object first_edition do
      assert_select '.date ', text: /Published/
    end

    assert_select_object updated_edition do
      assert_select '.date', text: /Updated/
    end
  end

  test "show should list organisation's working in the topic" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    topic = create(:topic, organisations: [first_organisation, second_organisation])

    get :show, id: topic

    assert_select ".meta" do
      assert_select_object first_organisation
      assert_select_object second_organisation
    end
  end

  test "should not display an empty organisation section" do
    topic = create(:topic)
    get :show, id: topic
    assert_select "#organisations", count: 0
  end

  test 'show has Atom feed autodiscovery link' do
    topic = build(:topic, id: 1)
    Topic.stubs(:find).returns(topic)
    get :show, id: topic
    assert_select_autodiscovery_link topic_url(topic, format: 'atom')
  end

  test 'show links to the atom feed' do
    topic = build(:topic, id: 1)
    Topic.stubs(:find).returns(topic)
    get :show, id: topic
    assert_select "a.feed[href=?]", topic_url(topic, format: 'atom')
  end

  test 'Atom feed has the right elements' do
    document = create(:document)
    topic = build(:topic, id: 1)
    topic.stubs(:recently_changed_documents).returns([build(:published_policy, document: document)])
    Topic.stubs(:find).returns(topic)

    get :show, id: topic, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', topic_url(topic, format: 'atom'), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', topic_url(topic), 1

      assert_select 'feed > entry' do |entries|
        entries.each do |entry|
          assert_select entry, 'entry > id', 1
          assert_select entry, 'entry > published', 1
          assert_select entry, 'entry > updated', 1
          assert_select entry, 'entry > link[rel=?][type=?]', 'alternate', 'text/html', 1
          assert_select entry, 'entry > title', 1
          assert_select entry, 'entry > content[type=?]', 'html', 1
        end
      end
    end
  end

  test 'Atom feed shows a list of recently published documents' do
    document = create(:document)
    recent_documents = [
      newer_edition = build(:published_policy, document: document, published_at: 1.day.ago),
      older_edition = build(:published_policy, document: document, published_at: 1.month.ago)
    ]
    topic = build(:topic, id: 1)
    topic.stubs(:recently_changed_documents).returns(recent_documents)
    Topic.stubs(:find).returns(topic)

    get :show, id: topic, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > updated', text: newer_edition.published_at.iso8601

      assert_select 'feed > entry' do |entries|
        entries.zip(recent_documents) do |entry, document|
          assert_select entry, 'entry > published', text: document.first_published_at.iso8601
          assert_select entry, 'entry > updated', text: document.published_at.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', text: document.title
          assert_select entry, 'entry > summary', text: document.summary
          assert_select entry, 'entry > content', text: /#{document.body}/
        end
      end
    end
  end

  test 'Atom feed only shows the last 10 recently changed documents' do
    document = create(:document)
    recent_documents = Array.new(20) {
      build(:published_policy, document: document)
    }
    topic = build(:topic, id: 1)
    topic.stubs(:recently_changed_documents).returns(recent_documents)
    Topic.stubs(:find).returns(topic)

    get :show, id: topic, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > entry', 10
    end
  end

  test "should show list of topics with published content" do
    topics = [0, 1, 2].map { |n| create(:topic, published_edition_count: n) }

    get :index

    refute_select_object(topics[0])
    assert_select_object(topics[1])
    assert_select_object(topics[2])
  end

  test "should not display an empty list of topics" do
    get :index

    refute_select ".topics"
  end
end
