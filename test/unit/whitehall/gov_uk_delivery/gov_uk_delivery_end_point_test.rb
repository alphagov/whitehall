# encoding: utf-8
require 'test_helper'

class Whitehall::GovUkDelivery::GovUkDeliveryEndPointTest < ActiveSupport::TestCase
  def assert_equal_ignoring_whitespace(expected, actual)
    assert_equal expected.gsub(/\s+/, ' ').strip, actual.gsub(/\s+/, ' ').strip
  end

  def govuk_delivery_notifier_for(edition, notification_date = Time.zone.now, *args)
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.new(edition, notification_date, *args)
  end

  def tags_for(edition, notification_date = Time.zone.now)
    govuk_delivery_notifier_for(edition, notification_date).tags
  end

  def email_body_for(edition, notification_date = Time.zone.now)
    govuk_delivery_notifier_for(edition, notification_date).email_body
  end

  test ".notify_from_queue! constructs an instance using the queue item and calls notify! on it" do
    policy = build(:policy, title: 'Foo', summary: 'Bar')
    queue_item = stub(edition: policy, notification_date: 3.days.ago, title: 'Baz', summary: 'Qux')
    notifier = mock()
    notifier.expects(:notify!)
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.expects(:new).with(policy, 3.days.ago, 'Baz', 'Qux').returns(notifier)
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.notify_from_queue!(queue_item)
  end

  test "uses the title of the edition if not specified" do
    policy = build(:policy, title: 'Meh')
    assert_equal 'Meh', govuk_delivery_notifier_for(policy).title
  end

  test "uses the supplied title" do
    policy = build(:policy, title: 'Meh')
    assert_equal 'Cheese', govuk_delivery_notifier_for(policy, Time.zone.now, 'Cheese').title
  end

  test '#display_title combines the title with the document type' do
    policy = Policy.new(title: 'Compulsory pickles for all')
    assert_equal 'Policy: Compulsory pickles for all', govuk_delivery_notifier_for(policy).display_title
  end

  test '#display_title uses an appropriate document type for world location new articles' do
    news = WorldLocationNewsArticle.new(title: 'Global pickle sales skyrocket')
    assert_equal 'News story: Global pickle sales skyrocket', govuk_delivery_notifier_for(news).display_title
  end

  test "uses the summary of the edition if not specified" do
    policy = build(:policy, title: 'Meh', summary: 'Woo')
    assert_equal 'Woo', govuk_delivery_notifier_for(policy).summary
  end

  test "uses the supplied summary" do
    policy = build(:policy, title: 'Meh', summary: 'Woo')
    assert_equal 'Hat', govuk_delivery_notifier_for(policy, Time.zone.now, 'Cheese', 'Hat').summary
  end

  test '#description returns the summary for a first edition' do
    first_edition = create(:published_publication)
    notifier = govuk_delivery_notifier_for(first_edition)
    assert_equal first_edition.summary, notifier.description
  end

  test '#description includes the change note for updated editions' do
    first_edition = create(:published_publication)
    second_edition = first_edition.create_draft(create(:departmental_editor))
    second_edition.change_note = "Updated some stuff"
    second_edition.save!
    assert second_edition.perform_force_publish
    notifier = govuk_delivery_notifier_for(second_edition)

    assert_equal "[Updated: #{second_edition.change_note}]<br /><br />#{second_edition.summary}", notifier.description
  end

  test "#tags returns a feed for 'all' by default" do
    assert tags_for(build(:policy)).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed"
  end

  test '#tags for a relevant to local government policy does not put the relevant to local param on the "all" feed url' do
    edition = build(:policy, relevant_to_local_government: true)

    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed?relevant_to_local_government=1"
  end

  test '#tags includes both a document specific and an "all" variant of the same params' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?topics%5B%5D=#{topic.slug}"
  end

  ### begin document type specific tests

  ### policy feed urls tests

  test '#tags returns an atom feed url for the organisation and a topic' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
  end

  test '#tags for a policy returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic1, topic2], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"
  end

  test '#tags for a policy returns an atom feed url that does not include topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}"
  end

  test '#tags for a policy returns an atom feed url that does not include departments' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?topics%5B%5D=#{topic.slug}"
  end

  test '#tags for a policy returns an atom feed url that does not include departments or topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom"
  end

  test '#tags for a relevant to local government policy puts the relevant to local param on some policies.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation], relevant_to_local_government: true)

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?relevant_to_local_government=1"

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom"
  end

  test "#tags includes policy activity feeds" do
    policy = create(:published_policy)
    edition = create(:news_article, related_policy_ids: [policy])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies/#{policy.slug}/activity.atom"
  end

  ### publications feed urls tests

  test '#tags for a publication returns an atom feed url for the organisation and a topic (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
  end

  test '#tags for a publication returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic1, topic2]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic1.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic2.slug}"
  end

  test '#tags for a publication returns an atom feed url that does not include topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports"
  end

  test '#tags for a publication returns an atom feed url that does not include departments (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
  end

  test '#tags for a publication returns an atom feed url that does not include departments or topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports"
  end

  test '#tags for a publication with a type that is not available as a filter returns an atom feed without a publication_filter_option' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:imported_publication, organisations: [organisation], publication_type: PublicationType::Unknown)
    edition.stubs(:topics).returns [topic]

    refute tags_for(edition).any? { |feed_url| feed_url =~ /publication_filter_option\=/ }
  end

  test '#tags for a relevant to local government publication puts the relevant to local param on some publications.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]
    # This value is inferred through parent policy in the full stack
    edition.stubs(:relevant_to_local_government?).returns true

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports&relevant_to_local_government=1"

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports"
  end

  ## announcements feed urls tests

  test '#tags for an announcement returns an atom feed url for the organisation and a topic (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
  end

  test '#tags for an announcement returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic1, topic2]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"
  end

  test '#tags for an announcement returns an atom feed url that does not include topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}"
  end

  test '#tags for an announcement returns an atom feed url that does not include departments (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&topics%5B%5D=#{topic.slug}"
  end

  test '#tags for an announcement returns an atom feed url that does not include departments or topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases"
  end

  test '#tags for an announcement with a type that is not available as a filter returns an atom feed without a announcement_filter_option' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation])
    edition.stubs(:news_article_type).returns(NewsArticleType::ImportedAwaitingType)
    edition.stubs(:topics).returns [topic]

    refute tags_for(edition).any? { |feed_url| feed_url =~ /announcement_filter_option\=/ }
  end

  test '#tags for a relevant to local government announcement puts the relevant to local param on some publications.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]
    # This value is inferred through parent policy in the full stack
    edition.stubs(:relevant_to_local_government?).returns true

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&relevant_to_local_government=1"

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases"
  end

  ## end document type specific tests

  test '#email_body generates a utf-8 encoded body' do
    publication = create(:news_article, title: "Café".encode("UTF-8"))

    body = email_body_for(publication)
    assert_includes body, publication.title
    assert_equal 'UTF-8', body.encoding.name
  end

  test "#email_body should link to full URL in email" do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    assert_match /#{Whitehall.public_host}/, email_body_for(publication)
  end

  test "#email_body includes the description and display_title" do
    first_draft = create(:published_publication)
    notifier = govuk_delivery_notifier_for(first_draft)

    body = Nokogiri::HTML.fragment(notifier.email_body)
    assert_equal_ignoring_whitespace notifier.display_title, body.css('.rss_title').inner_text
    assert_equal_ignoring_whitespace notifier.description, body.css('.rss_description').inner_text
  end

  test "#email_body includes a formatted date" do
    publication = create(:publication)
    body = Nokogiri::HTML.fragment(email_body_for(publication, Time.zone.parse("2011-01-01 12:13:14")))
    assert_equal_ignoring_whitespace "1 January, 2011 at 12:13pm", body.css('.rss_pub_date').inner_text
  end

  test '#email_body html-escapes html characters in the title, change note and summary' do
    first_draft = create(:published_publication, title: 'Beards & Facial Hair', summary: 'Keep your beard "tip-top"!')
    second_draft = first_draft.create_draft(create(:departmental_editor))
    second_draft.change_note = '"tip-top" added.'
    second_draft.save!
    second_draft.perform_force_publish

    body = email_body_for(second_draft)
    assert_match %r(Beards &amp; Facial Hair), body
    assert_match %r(&quot;tip-top&quot; added), body
    assert_match %r(Keep your beard &quot;tip-top&quot;!), body
  end

  test '#notify! queues a notification job to be performed later' do
    policy = create(:policy)
    notifier = govuk_delivery_notifier_for(policy)

    assert_difference 'Delayed::Job.count', 1 do
      notifier.notify!
    end

    payload_object = Delayed::Job.last.payload_object
    assert payload_object.is_a?(GovUkDeliveryNotificationJob)
    assert_equal notifier, payload_object.notifier
  end

end
