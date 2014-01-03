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
    @edition = build(:policy)
    assert_subscription_urls_for_edition_include("feed")
  end

  test '#subscription_urls for a relevant to local government policy does not put the relevant to local param on the "all" feed url' do
    @edition = build(:policy, relevant_to_local_government: true)

    refute urls_for(@edition).include? feed_url("feed?relevant_to_local_government=1")
  end

  test '#subscription_urls includes both a document specific and an "all" variant of the same params' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include(
      "policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "feed?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "feed?departments%5B%5D=#{organisation.slug}",
      "feed?topics%5B%5D=#{topic.slug}",
      "policies.atom?departments%5B%5D=#{organisation.slug}",
      "policies.atom?topics%5B%5D=#{topic.slug}"
    )
  end

  test '#subscription_urls returns an atom feed url for the organisation and a topic' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}")
  end

  test '#subscription_urls for a policy returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic1, topic2], organisations: [organisation])

    assert_subscription_urls_for_edition_include(
      "policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}",
      "policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"
    )
  end

  test '#subscription_urls for a policy returns an atom feed url that does not include topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("policies.atom?departments%5B%5D=#{organisation.slug}")
  end

  test '#subscription_urls for a policy returns an atom feed url that does not include departments' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("policies.atom?topics%5B%5D=#{topic.slug}")
  end

  test '#subscription_urls for a policy returns an atom feed url that does not include departments or topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic], organisations: [organisation])

    assert_subscription_urls_for_edition_include("policies.atom")
  end

  test '#subscription_urls for a relevant to local government policy puts the relevant to local param on some policies.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:policy, topics: [topic], organisations: [organisation], relevant_to_local_government: true)

    assert_subscription_urls_for_edition_include(
      "policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1",
      "policies.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "policies.atom?relevant_to_local_government=1",
      "policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "policies.atom?departments%5B%5D=#{organisation.slug}",
      "policies.atom?topics%5B%5D=#{topic.slug}",
      "policies.atom"
    )
  end

  test "#subscription_urls includes policy activity feeds" do
    policy = create(:published_policy)
    @edition = create(:news_article, related_policy_ids: [policy])

    assert_subscription_urls_for_edition_include("policies/#{policy.slug}/activity.atom")
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

  test '#subscription_urls for a relevant to local government publication puts the relevant to local param on some publications.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    @edition.stubs(:topics).returns [topic]
    # This value is inferred through parent policy in the full stack
    @edition.stubs(:relevant_to_local_government?).returns true

    assert_subscription_urls_for_edition_include(
      "publications.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1",
      "publications.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "publications.atom?relevant_to_local_government=1",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&relevant_to_local_government=1",
      "publications.atom?publication_filter_option=corporate-reports&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "publications.atom?publication_filter_option=corporate-reports&relevant_to_local_government=1",
      "publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}",
      "publications.atom?topics%5B%5D=#{topic.slug}",
      "publications.atom",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}",
      "publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports",
      "publications.atom?publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}",
      "publications.atom?publication_filter_option=corporate-reports"
    )
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
    @edition.stubs(:news_article_type).returns(NewsArticleType::ImportedAwaitingType)
    @edition.stubs(:topics).returns [topic]

    refute urls_for(@edition).any? { |feed_url| feed_url =~ /announcement_filter_option\=/ }
  end

  test '#subscription_urls for a relevant to local government announcement puts the relevant to local param on some publications.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    @edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    @edition.stubs(:topics).returns [topic]
    # This value is inferred through parent policy in the full stack
    @edition.stubs(:relevant_to_local_government?).returns true

    assert_subscription_urls_for_edition_include(
      "announcements.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "announcements.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1",
      "announcements.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "announcements.atom?relevant_to_local_government=1",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1",
      "announcements.atom?announcement_filter_option=press-releases&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}",
      "announcements.atom?announcement_filter_option=press-releases&relevant_to_local_government=1",
      "announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "announcements.atom?departments%5B%5D=#{organisation.slug}",
      "announcements.atom?topics%5B%5D=#{topic.slug}",
      "announcements.atom",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}",
      "announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}",
      "announcements.atom?announcement_filter_option=press-releases&topics%5B%5D=#{topic.slug}",
      "announcements.atom?announcement_filter_option=press-releases"
    )
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

end
