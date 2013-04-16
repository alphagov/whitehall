# encoding: utf-8

require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase

  def assert_equal_ignoring_whitespace(expected, actual)
    assert_equal expected.gsub(/\s+/, ' ').strip, actual.gsub(/\s+/, ' ').strip
  end

  def notifier_for(edition)
    Edition::GovUkDelivery::Notifier.new(edition)
  end

  def notification_date_for(edition)
    notifier_for(edition).notification_date
  end

  def govuk_delivery_notifier_for(edition, notification_date = Time.zone.now, *args)
    Edition::GovUkDelivery::Notifier::GovUkDelivery.new(edition, notification_date, *args)
  end

  def tags_for(edition, notification_date = Time.zone.now)
    govuk_delivery_notifier_for(edition, notification_date).govuk_delivery_tags
  end

  def email_body_for(edition, notification_date = Time.zone.now)
    govuk_delivery_notifier_for(edition, notification_date).govuk_delivery_email_body
  end

  def email_curation_queue_notifier_for(edition, notification_date = Time.zone.now)
    Edition::GovUkDelivery::Notifier::EmailCurationQueue.new(edition, notification_date)
  end

  test "should notify on publishing policies" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    notifier = notifier_for(policy)
    Edition::GovUkDelivery::Notifier.expects(:new).with(policy).returns(notifier)
    notifier.expects(:edition_published!).once
    policy.publish!
  end

  test "should notify on publishing news articles" do
    news_article = create(:news_article)
    news_article.first_published_at = Time.zone.now
    news_article.major_change_published_at = Time.zone.now

    notifier = notifier_for(news_article)
    Edition::GovUkDelivery::Notifier.expects(:new).with(news_article).returns(notifier)
    notifier.expects(:edition_published!).once
    news_article.publish!
  end

  test "should notify on publishing publications" do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    notifier = notifier_for(publication)
    Edition::GovUkDelivery::Notifier.expects(:new).with(publication).returns(notifier)
    notifier.expects(:edition_published!).once
    publication.publish!
  end

  test 'Notifier#edition_published! will route the edition to govuk delivery if it is not relevant to local government' do
    edition = build(:edition, relevant_to_local_government: false, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns true
    notifier = notifier_for(edition)
    notification_end_point = govuk_delivery_notifier_for(edition)
    Edition::GovUkDelivery::Notifier::GovUkDelivery.expects(:new).with(edition, anything).returns(notification_end_point).once
    Edition::GovUkDelivery::Notifier::EmailCurationQueue.expects(:new).never

    notifier.edition_published!
  end

  test 'Notifier#edition_published! will route the edition to the email curation queue if it is relevant to local government' do
    edition = build(:edition, relevant_to_local_government: true, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns true
    notifier = notifier_for(edition)
    notification_end_point = email_curation_queue_notifier_for(edition)
    Edition::GovUkDelivery::Notifier::GovUkDelivery.expects(:new).never
    Edition::GovUkDelivery::Notifier::EmailCurationQueue.expects(:new).with(edition, anything).returns(notification_end_point).once

    notifier.edition_published!
  end

  test 'Notifier#edition_published! does nothing if the change is minor' do
    policy = create(:policy, topics: [create(:topic)], minor_change: true, public_timestamp: Time.zone.now)
    notifier = notifier_for(policy)
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test 'Notifier#edition_published! does nothing if the edition is not available in english' do
    speech = I18n.with_locale(:es) { create(:published_speech, minor_change: false, major_change_published_at: Time.zone.now) }
    speech.stubs(:topics).returns [create(:topic)]
    notifier = notifier_for(speech)
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test 'Notifier#edition_published! does nothing if the edition notification date is not today' do
    policy = create(:policy, topics: [create(:topic)], minor_change: false, public_timestamp: Time.zone.now)
    notifier = notifier_for(policy)
    notifier.stubs(:notification_date).returns 2.days.ago
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test "Notifier::GovukDelivery.notify_from_queue! constructs an instance using the queue item and calls notify! on it" do
    policy = build(:policy, title: 'Foo', summary: 'Bar')
    queue_item = stub(edition: policy, notification_date: 3.days.ago, title: 'Baz', summary: 'Qux')
    notifier = mock()
    notifier.expects(:notify!)
    Edition::GovUkDelivery::Notifier::GovUkDelivery.expects(:new).with(policy, 3.days.ago, 'Baz', 'Qux').returns(notifier)
    Edition::GovUkDelivery::Notifier::GovUkDelivery.notify_from_queue!(queue_item)
  end

  test "Notifier::GovukDelivery uses the title of the edition if not specified" do
    policy = build(:policy, title: 'Meh')
    assert_equal 'Meh', govuk_delivery_notifier_for(policy).title
  end

  test "Notifier::GovukDelivery uses the supplied title" do
    policy = build(:policy, title: 'Meh')
    assert_equal 'Cheese', govuk_delivery_notifier_for(policy, Time.zone.now, 'Cheese').title
  end

  test "Notifier::GovukDelivery uses the summary of the edition if not specified" do
    policy = build(:policy, title: 'Meh', summary: 'Woo')
    assert_equal 'Woo', govuk_delivery_notifier_for(policy).summary
  end

  test "Notifier::GovukDelivery uses the supplied title summary" do
    policy = build(:policy, title: 'Meh', summary: 'Woo')
    assert_equal 'Hat', govuk_delivery_notifier_for(policy, Time.zone.now, 'Cheese', 'Hat').summary
  end

  test "Notifier::GovUkDelivery#govuk_delivery_tags returns a feed for 'all' by default" do
    assert tags_for(build(:policy)).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a relevant to local government policy does not put the relevant to local param on the "all" feed url' do
    edition = build(:policy, relevant_to_local_government: true)

    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/feed?relevant_to_local_government=1"
  end

  ### begin document type specific tests

  ### policy feed urls tests

  test 'Notifier::GovUkDelivery#govuk_delivery_tags returns an atom feed url for the organisation and a topic' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a policy returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic1, topic2], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a policy returns an atom feed url that does not include topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a policy returns an atom feed url that does not include departments' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?topics%5B%5D=#{topic.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a policy returns an atom feed url that does not include departments or topics' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a relevant to local government policy puts the relevant to local param on all policies.atom urls' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation], relevant_to_local_government: true)

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?relevant_to_local_government=1"

    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom?topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/policies.atom"
  end

  ### publications feed urls tests

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a publication returns an atom feed url for the organisation and a topic (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a publication returns an atom feed url for each topic/organisation combination' do
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

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a publication returns an atom feed url that does not include topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a publication returns an atom feed url that does not include departments (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a publication returns an atom feed url that does not include departments or topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::CorporateReport)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a publication with a type that is not available as a filter returns an atom feed without a publication_filter_option' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:publication, organisations: [organisation], publication_type: PublicationType::Unknown)
    edition.stubs(:topics).returns [topic]

    refute tags_for(edition).any? { |feed_url| feed_url =~ /publication_filter_option\=/ }
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a relevant to local government publication puts the relevant to local param on all publications.atom urls' do
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

    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=corporate-reports"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=corporate-reports"
  end

  ## announcements feed urls tests

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for an announcement returns an atom feed url for the organisation and a topic (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for an announcement returns an atom feed url for each topic/organisation combination' do
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

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for an announcement returns an atom feed url that does not include topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for an announcement returns an atom feed url that does not include departments (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?topics%5B%5D=#{topic.slug}"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&topics%5B%5D=#{topic.slug}"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for an announcement returns an atom feed url that does not include departments or topics (with and without the publication_filter_option param)' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation], news_article_type: NewsArticleType::PressRelease)
    edition.stubs(:topics).returns [topic]

    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom"
    assert tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases"
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for an announcement with a type that is not available as a filter returns an atom feed without a announcement_filter_option' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:news_article, organisations: [organisation])
    edition.stubs(:news_article_type).returns(NewsArticleType::ImportedAwaitingType)
    edition.stubs(:topics).returns [topic]

    refute tags_for(edition).any? { |feed_url| feed_url =~ /announcement_filter_option\=/ }
  end

  test 'Notifier::GovUkDelivery#govuk_delivery_tags for a relevant to local government announcement puts the relevant to local param on all publications.atom urls' do
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

    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?departments%5B%5D=#{organisation.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&departments%5B%5D=#{organisation.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases&topics%5B%5D=#{topic.slug}"
    refute tags_for(edition).include? "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/announcements.atom?announcement_filter_option=press-releases"
  end

  ## end document type specific tests

  test 'Notifier::GovUkDelivery#govuk_delivery_email_body generates a utf-8 encoded body' do
    publication = create(:news_article, title: "Café".encode("UTF-8"))

    body = email_body_for(publication)
    assert_includes body, publication.title
    assert_equal 'UTF-8', body.encoding.name
  end

  test "Notifier::GovUkDelivery#govuk_delivery_email_body should link to full URL in email" do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    assert_match /#{Whitehall.public_host}/, email_body_for(publication)
  end

  test "Notifier::GovUkDelivery#govuk_delivery_email_body should include change note along with summary in an updated edition" do
    editor = create(:departmental_editor)
    first_draft = create(:published_publication)
    second_draft = first_draft.create_draft(editor)
    second_draft.change_note = "Updated some stuff"
    second_draft.save!
    assert second_draft.publish_as(editor, force: true)

    body = Nokogiri::HTML.fragment(email_body_for(second_draft))
    assert_equal_ignoring_whitespace "Updated #{second_draft.title}", body.css('.rss_title').inner_text
    assert_equal_ignoring_whitespace second_draft.change_note + second_draft.summary, body.css('.rss_description').inner_text
  end

  test "Notifier::GovUkDelivery#govuk_delivery_email_body includes summary in the first published edition" do
    editor = create(:departmental_editor)
    first_draft = create(:published_publication)

    body = Nokogiri::HTML.fragment(email_body_for(first_draft))
    assert_equal_ignoring_whitespace first_draft.title, body.css('.rss_title').inner_text
    assert_equal_ignoring_whitespace first_draft.summary, body.css('.rss_description').inner_text
  end

  test "Notifier::GovUkDelivery#govuk_delivery_email_body includes a formatted date" do
    publication = create(:publication)
    body = Nokogiri::HTML.fragment(email_body_for(publication, Time.zone.parse("2011-01-01 12:13:14")))
    assert_equal_ignoring_whitespace "1 January, 2011 at 12:13pm", body.css('.rss_pub_date').inner_text
  end

  test "Notifier::GovUkDelivery#notification_date uses the major_change_published_at for the notification_date of speeches" do
    speech = create(:speech)
    speech.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    speech.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')
    assert_equal notification_date_for(speech), Time.zone.parse('2011-01-01 12:13:14')
  end

  test "Notifier::GovUkDelivery#notification_date uses the public_timestamp for the notification_date of other editions" do
    policy = create(:policy)
    policy.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    policy.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')
    assert_equal notification_date_for(policy), Time.zone.parse('2010-12-31 12:13:14')
  end

  test 'Notifier::GovUkDelivery#notify! sends a notification via the govuk delivery client when there are topics' do
    policy = create(:policy, topics: [create(:topic)])
    policy.stubs(:public_timestamp).returns Time.zone.now
    notifier = govuk_delivery_notifier_for(policy)
    notifier.stubs(:govuk_delivery_email_body).returns('email body')
    Whitehall.govuk_delivery_client.expects(:notify).with(notifier.govuk_delivery_tags, policy.title, 'email body')

    notifier.notify!
  end

  test 'Notifier::GovUkDelivery#notify! swallows errors from the API' do
    policy = create(:policy, topics: [create(:topic)])
    policy.public_timestamp = Time.zone.now
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 500)

    assert_nothing_raised { govuk_delivery_notifier_for(policy).notify! }
  end

  test 'Notifier::GovUkDelivery#notify! swallows timeout errors from the API' do
    policy = create(:policy, topics: [create(:topic)])
    policy.public_timestamp = Time.zone.now
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::TimedOutException)

    assert_nothing_raised { govuk_delivery_notifier_for(policy).notify! }
  end

  test 'Notifier::EmailCurationQueue#notify! constructs a new EmailCurationQueueItem based on the edition' do
    policy = create(:policy, topics: [create(:topic)])
    notifier = email_curation_queue_notifier_for(policy, 1.day.ago)
    EmailCurationQueueItem.expects(:create_from_edition).with(policy, 1.day.ago)

    notifier.notify!
  end
end
