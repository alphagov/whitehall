require "test_helper"
require 'gds_api/test_helpers/content_store'

class TopicsControllerTest < ActionController::TestCase
  include FeedHelper
  include GdsApi::TestHelpers::ContentStore

  should_be_a_public_facing_controller

  view_test "GET :shows lists the topic details, setting the expiry headers based on the scheduled editions" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    publication = create(:draft_publication, :scheduled)
    topic = create_topic_and_stub_content_store(editions: [publication, create(:published_news_article)])
    topic.organisations << organisation_1
    topic.organisations << organisation_2

    controller.expects(:expire_on_next_scheduled_publication).with(topic.scheduled_editions)

    get :show, params: { id: topic }

    assert_select "h1", text: topic.name
    assert_select ".govspeak", text: topic.description
    assert_equal topic.description, assigns(:meta_description)
    assert_select "a[href=?]", organisation_path(organisation_1)
    assert_select "a[href=?]", organisation_path(organisation_2)
  end

  view_test "GET :show includes the data tracking module" do
    topic = create_topic_and_stub_content_store
    get :show, params: { id: topic }

    assert_select(".topic[data-module='track-click']")
  end

  view_test "GET :show lists published publications and links to more with tracking attributes" do
    topic = create_topic_and_stub_content_store
    published = []
    4.times do |i|
      published << create(:published_publication, title: "title-#{i}", topics: [topic], first_published_at: i.days.ago)
    end

    get :show, params: { id: topic }

    assert_select "#publications" do
      published.take(3).each_with_index do |edition, edition_index|
        data_attributes = build_data_attributes_for(
          'Publications',
          edition,
          edition_index
        )

        assert_select(
          "a#{data_attributes}",
          text: edition.title,
          href: public_document_path(edition)
        )

        assert_select_object(edition) do
          assert_select "h2", text: edition.title
        end
      end
      refute_select_object(published[3])
    end
  end

  view_test "GET :show lists published consultations and links to more with tracking attributes" do
    topic = create_topic_and_stub_content_store
    published = []
    4.times do |i|
      published << create(:published_consultation, title: "title-#{i}", topics: [topic], first_published_at: i.days.ago)
    end

    get :show, params: { id: topic }

    assert_select "#consultations" do
      published.take(3).each_with_index do |edition, edition_index|
        data_attributes = build_data_attributes_for(
          'Consultations',
          edition,
          edition_index
        )

        assert_select(
          "a#{data_attributes}",
          text: edition.title,
          href: public_document_path(edition)
        )
      end
      refute_select "a", text: published[3].title
    end
  end

  view_test "GET :show lists published statistical publications and links to more with tracking attributes" do
    topic = create_topic_and_stub_content_store
    published = []
    4.times do |i|
      published << create(:published_statistics, title: "title-#{i}", topics: [topic], first_published_at: i.days.ago)
    end

    get :show, params: { id: topic }

    assert_select "#statistics" do
      published.take(3).each_with_index do |edition, edition_index|
        data_attributes = build_data_attributes_for(
          'Statistics',
          edition,
          edition_index
        )

        assert_select(
          "a#{data_attributes}",
          text: edition.title,
          href: public_document_path(edition)
        )
      end
      refute_select "a", text: published[3].title
    end
  end

  view_test "GET :show lists published announcements and links to more with tracking attributes" do
    topic = create_topic_and_stub_content_store
    published = []
    4.times do |i|
      published << create(:published_news_article, title: "title-#{i}", topics: [topic], first_published_at: i.days.ago)
    end

    get :show, params: { id: topic }

    assert_select "#announcements" do
      published.take(3).each_with_index do |edition, edition_index|
        data_attributes = build_data_attributes_for(
          'Announcements',
          edition,
          edition_index
        )

        assert_select(
          "a#{data_attributes}",
          text: edition.title,
          href: public_document_path(edition)
        )

        assert_select_object(edition) do
          assert_select "h2", text: edition.title
        end
      end
      refute_select_object(published[3])
    end
  end

  view_test "GET :show lists 5 published detailed guides and links to more with tracking attributes" do
    published_detailed_guides = []
    6.times do |i|
      published_detailed_guides << create(:published_detailed_guide, title: "detailed-guide-title-#{i}")
    end
    topic = create_topic_and_stub_content_store(editions: published_detailed_guides)

    get :show, params: { id: topic }

    assert_select ".detailed-guidance" do
      published_detailed_guides.take(5).each_with_index do |guide, guide_index|
        assert_select_object(guide) do
          assert_select "h2", text: guide.title
        end

        data_attributes = build_data_attributes_for(
          'DetailedGuides',
          guide,
          guide_index,
          total: '5'
        )

        assert_select(
          "a#{data_attributes}",
          text: guide.title,
          href: public_document_path(guide)
        )
      end
      refute_select_object(published_detailed_guides[5])
    end
  end

  view_test "GET :show displays latest documents relating to the topic, including atom feed and govdelivery links" do
    topic = create_topic_and_stub_content_store
    publication_1 = create(:published_publication, topics: [topic])
    news_article = create(:published_news_article, topics: [topic])
    publication_2 = create(:published_publication, topics: [topic])
    create(:classification_featuring, classification: topic, edition: publication_1)

    get :show, params: { id: topic }

    assert_select "#recently-updated" do
      assert_select_prefix_object publication_1, prefix = "recent"
      assert_select_prefix_object publication_2, prefix = "recent"
      assert_select_prefix_object news_article, prefix = "recent"
    end

    assert_select ".govdelivery[href='#{new_email_signups_path(email_signup: { feed: atom_feed_url_for(topic) })}']"
    assert_select_autodiscovery_link atom_feed_url_for(topic)
  end

  view_test 'GET :show for atom feed has the right elements' do
    topic = create_topic_and_stub_content_store
    publication = create(:published_publication, topics: [topic])

    get :show, params: { id: topic }, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', topic_url(topic, format: 'atom'), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', topic_url(topic), 1

      assert_select_atom_entries([publication])
    end
  end

  test 'GET :show has a 5 minute expiry time' do
    topic = create_topic_and_stub_content_store
    get :show, params: { id: topic }

    assert_cache_control("max-age=#{5.minutes}")
  end

  test 'GET :show caps max expiry to 5 minute when there are future scheduled editions' do
    topic = create_topic_and_stub_content_store
    create(:scheduled_publication, scheduled_publication: 1.day.from_now, topics: [topic])

    get :show, params: { id: topic }

    assert_cache_control("max-age=#{5.minutes}")
  end

  test 'GET :show sets analytics organisation headers' do
    organisation = create(:organisation)
    topic = create_topic_and_stub_content_store
    topic.organisations << organisation

    get :show, params: { id: topic }

    assert_equal "<#{organisation.analytics_identifier}>", response.headers["X-Slimmer-Organisations"]
  end

  def create_topic_and_stub_content_store(*args)
    topic = create(:topic, *args)
    payload = {
      format: "topic",
      title: "Title of topic",
    }
    content_store_has_item(topic.base_path, payload)

    topic
  end

  def build_data_attributes_for(type, edition, edition_index, total: '3')
    track_options = { dimension28: total, dimension29: edition.title }

    [
      "[data-track-category='navPolicyAreaLinkClicked']",
      "[data-track-action='#{type}.#{edition_index + 1}']",
      "[data-track-label='#{public_document_path(edition)}']",
      "[data-track-options='#{JSON.dump(track_options)}']"
    ].join('')
  end
end
