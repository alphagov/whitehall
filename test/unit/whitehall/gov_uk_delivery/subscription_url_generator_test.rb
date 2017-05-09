# encoding: utf-8
require 'test_helper'

class Whitehall::GovUkDelivery::SubscriptionUrlGeneratorTest < ActiveSupport::TestCase

  def feed_url(url_fragment)
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/#{url_fragment}"
  end

  def urls_for(edition)
    Whitehall::GovUkDelivery::SubscriptionUrlGenerator.new(edition).subscription_urls
  end

  def assert_subscription_urls_for_edition_include(*url_fragments)
    actual_subscription_urls = urls_for(@edition)
    url_fragments.each do |url_fragment|
      assert_includes actual_subscription_urls, feed_url(url_fragment)
    end
  end

  test "#subscription_urls returns a feed for 'all' by default" do
    @edition = build(:publication)
    assert_subscription_urls_for_edition_include("feed")
  end

  test '#subscription_urls includes both a document specific and an "all" variant of the same params' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include(
      "publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "feed?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "feed?departments%5B%5D=#{organisation.slug}",
      "feed?topics%5B%5D=#{topic.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}",
      "publications.atom?topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls returns an atom feed url for the organisation and a topic' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}")
  end

  test '#subscription_urls for a publication returns an atom feed url that does not include topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("publications.atom?departments%5B%5D=#{organisation.slug}")
  end

  test '#subscription_urls for a publication returns an atom feed url that does not include departments' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("publications.atom?topics%5B%5D=#{topic.slug}")
  end

  test '#subscription_urls for a publication returns an atom feed url that does not include departments or topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("publications.atom")
  end

  test '#subscription_urls for a publication returns an atom feed url for the organisation and a topic (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls for a publication returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    @edition.stubs(:topics).returns [topic1, topic2]

    assert_subscription_urls_for_edition_include(
      "publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic1.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic2.slug}"
    )
  end

  test '#subscription_urls for a publication returns an atom feed url that does not include topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "publications.atom?departments%5B%5D=#{organisation.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports"
    )
  end

  test '#subscription_urls for a publication returns an atom feed url that does not include departments (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "publications.atom?topics%5B%5D=#{topic.slug}",
      "publications.atom?publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls for a publication returns an atom feed url that does not include departments or topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "publications.atom",
      "publications.atom?publication_filter_option=corporate-reports"
    )
  end

  test '#subscription_urls for a publication with a type that is not available as a filter returns an atom feed without a publication_filter_option' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:imported_publication, organisations: [organisation], publication_type: PublicationType::Unknown)
    @edition.stubs(:topics).returns [topic]

    refute urls_for(@edition).any? { |feed_url| feed_url =~ /publication_filter_option\=/ }
  end

  test '#subscription_urls for an announcement returns an atom feed url for the organisation and a topic (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls for an announcement returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    @edition.stubs(:topics).returns [topic1, topic2]

    assert_subscription_urls_for_edition_include(
      "announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}",
      "announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"
    )
  end

  test '#subscription_urls for an announcement returns an atom feed url that does not include topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "announcements.atom?departments%5B%5D=#{organisation.slug}",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}"
    )
  end

  test '#subscription_urls for an announcement returns an atom feed url that does not include departments (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "announcements.atom?topics%5B%5D=#{topic.slug}",
      "announcements.atom?announcement_filter_option=press-releases&topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls for an announcement returns an atom feed url that does not include departments or topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    @edition.stubs(:topics).returns [topic]

    assert_subscription_urls_for_edition_include(
      "announcements.atom",
      "announcements.atom?announcement_filter_option=press-releases"
    )
  end

  test '#subscription_urls for an announcement with a type that is not available as a filter returns an atom feed without a announcement_filter_option' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation])
    @edition.stubs(:news_article_type).returns(NewsArticleType::WorldwideNewsStory)
    @edition.stubs(:topics).returns [topic]

    refute urls_for(@edition).any? { |feed_url| feed_url =~ /announcement_filter_option\=/ }
  end

  test '#subscription_urls for an announcement includes the atom feed for the associated role and person' do
    appointment1 = create(:ministerial_role_appointment)
    appointment2 = create(:ministerial_role_appointment)

    @edition = create(:news_article, role_appointments: [appointment1, appointment2])

    assert_subscription_urls_for_edition_include(
      "people/#{appointment1.person.slug}.atom",
      "ministers/#{appointment1.role.slug}.atom",
      "people/#{appointment2.person.slug}.atom",
      "ministers/#{appointment2.role.slug}.atom"
    )
  end

  test '#subscription_urls handles speeches that have a person override instead of a role appointment' do
    @edition = create(:speech, role_appointment: nil, person_override: 'The Queen')

    assert_subscription_urls_for_edition_include('announcements.atom')
  end

  test '#subscription_urls for a speech includes the atom feed for the associated role and person' do
    appointment1 = create(:ministerial_role_appointment)

    @edition = create(:speech, role_appointment: appointment1)

    assert_subscription_urls_for_edition_include(
      "people/#{appointment1.person.slug}.atom",
      "ministers/#{appointment1.role.slug}.atom"
    )
  end

  test '#subscription_urls for an edition related to topics includes the atom feed for both the generic feed and the specific topic feed' do
    topic = create(:topic)
    @edition = create(:news_article, topics: [topic])

    assert_subscription_urls_for_edition_include(
      "topics/#{topic.slug}.atom",
      "feed?topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls for an edition related to topical events includes the atom feed for the specific topical_event feed' do
    topical_event = create(:topical_event)
    @edition = create(:news_article, topical_events: [topical_event])

    assert_subscription_urls_for_edition_include("topical-events/#{topical_event.slug}.atom")
  end

  test '#subscription_urls for an edition related to a world location includes the atom feed for the specific world location feed' do
    world_location = create(:world_location)
    @edition = create(:world_location_news_article, world_locations: [world_location])

    assert_subscription_urls_for_edition_include("world/#{world_location.slug}.atom")
  end

  test "#subscription_urls for an edition related to an organisation includes the atom feed for both the generic feed and the specific organisation's feed" do
    organisation = create(:organisation)
    @edition = create(:news_article, organisations: [organisation])

    assert_subscription_urls_for_edition_include(
      "organisations/#{organisation.slug}.atom",
      "feed?departments%5B%5D=#{organisation.slug}"
    )
  end

  test "#subscription_urls for an Official Statistics publication returns atom feed urls for both publications and statistics" do
    @edition = create(:publication, publication_type: PublicationType::OfficialStatistics)

    assert_subscription_urls_for_edition_include(
      "publications.atom",
      "publications.atom?publication_filter_option=statistics",
      "statistics.atom",
      "statistics.atom?publication_filter_option=statistics",
    )
  end

  test "#subscription_urls for a National Statistics publication returns atom feed urls for both publications and statistics" do
    @edition = create(:publication, publication_type: PublicationType::NationalStatistics)

    assert_subscription_urls_for_edition_include(
      "publications.atom",
      "publications.atom?publication_filter_option=statistics",
      "statistics.atom",
      "statistics.atom?publication_filter_option=statistics",
    )
  end

  test "#subscription_urls for a statistical data set returns atom feed urls for both publications and statistics" do
    @edition = create(:statistical_data_set)

    assert_subscription_urls_for_edition_include(
      "publications.atom",
      "publications.atom?publication_filter_option=statistics",
      "statistics.atom",
      "statistics.atom?publication_filter_option=statistics",
    )
  end
end
