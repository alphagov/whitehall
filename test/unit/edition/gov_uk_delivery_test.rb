# encoding: utf-8

require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase

  def assert_equal_ignoring_whitespace(expected, actual)
    assert_equal expected.gsub(/\s+/, ' ').strip, actual.gsub(/\s+/, ' ').strip
  end

  test "#govuk_delivery_tags returns a feed for 'all' by default" do
    assert_equal ["https://#{Whitehall.public_host}/government/feed"], build(:policy).govuk_delivery_tags
  end

  test '#govuk_delivery_tags returns an atom feed url for the organisation and a topic' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert edition.govuk_delivery_tags.include? "https://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"

  end

  test '#govuk_delivery_tags returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic1, topic2], organisations: [organisation])

    assert edition.govuk_delivery_tags.include? "https://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert edition.govuk_delivery_tags.include? "https://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"
  end

  test '#govuk_delivery_tags returns an atom feed url that does not include departments as well as a regular URL' do
    topic1 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic1], organisations: [organisation])

    assert edition.govuk_delivery_tags.include? "https://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}"
    assert edition.govuk_delivery_tags.include? "https://#{Whitehall.public_host}/government/policies.atom?topics%5B%5D=#{topic1.slug}"
  end

  test '#govuk_delivery_tags includes relevant to local param if edition is relevant' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation], relevant_to_local_government: true)

    assert edition.govuk_delivery_tags.include? "https://#{Whitehall.public_host}/government/policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=1&topics%5B%5D=#{topic.slug}"
  end

  test '#govuk_delivery_email_body generates a utf-8 encoded body' do
    publication = create(:news_article, title: "Café".encode("UTF-8"))

    body = publication.govuk_delivery_email_body
    assert_includes body, publication.title
    assert_equal 'UTF-8', body.encoding.name
  end

  test '#govuk_delivery_email_body should link to full URL in email' do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    assert_match /#{Whitehall.public_host}/, publication.govuk_delivery_email_body
  end

  test '#notify_govuk_delivery sends a notification via the govuk delivery client when there are topics' do
    policy = create(:policy, topics: [create(:topic)])
    policy.stubs(:govuk_delivery_email_body).returns('email body')
    policy.stubs(:public_timestamp).returns Time.zone.now
    Whitehall.govuk_delivery_client.expects(:notify).with(policy.govuk_delivery_tags, policy.title, 'email body')

    policy.notify_govuk_delivery
  end

  test '#notify_govuk_delivery swallows errors from the API' do
    policy = create(:policy, topics: [create(:topic)])
    policy.stubs(:public_timestamp).returns Time.zone.now
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 500)

    assert_nothing_raised { policy.notify_govuk_delivery }
  end

  test '#notify_govuk_delivery swallows timeout errors from the API' do
    policy = create(:policy, topics: [create(:topic)])
    policy.stubs(:public_timestamp).returns Time.zone.now
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::TimedOutException)

    assert_nothing_raised { policy.notify_govuk_delivery }
  end

  test "notifies gov uk delivery after publishing a policy" do
    policy = create(:policy)
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    policy.expects(:notify_govuk_delivery).once
    policy.publish!
  end

  test "notifies gov uk delivery after publishing a news article" do
    news_article = create(:news_article)
    news_article.first_published_at = Time.zone.now
    news_article.major_change_published_at = Time.zone.now

    news_article.expects(:notify_govuk_delivery).once
    news_article.publish!
  end

  test "notifies gov uk delivery after publishing a publication" do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    publication.expects(:notify_govuk_delivery).once
    publication.publish!
  end

  test 'does not notify gov uk delivery if the change was minor' do
    policy = create(:policy, minor_change: true)
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    policy.expects(:notify_govuk_delivery).never
    policy.publish!
  end

  test "#govuk_delivery_email_body should include change note in an updated edition" do
    editor = create(:departmental_editor)
    first_draft = create(:published_publication)
    second_draft = first_draft.create_draft(editor)
    second_draft.change_note = "Updated some stuff"
    second_draft.save!
    assert second_draft.publish_as(editor, force: true)

    body = Nokogiri::HTML.fragment(second_draft.govuk_delivery_email_body)
    assert_equal_ignoring_whitespace "Updated #{second_draft.title}", body.css('.rss_title').inner_text
    assert_equal_ignoring_whitespace second_draft.change_note, body.css('.rss_description').inner_text
  end

  test "#govuk_delivery_email_body should include a formatted date" do
    publication = create(:publication)
    publication.stubs(:public_timestamp).returns Time.zone.parse("2011-01-01 12:13:14")
    body = Nokogiri::HTML.fragment(publication.govuk_delivery_email_body)
    assert_equal_ignoring_whitespace "1 January, 2011 at 12:13pm", body.css('.rss_pub_date').inner_text
  end

  test "#govuk_delivery_email_body should include a speech published date date" do
    speech = create(:speech)
    speech.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    speech.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')
    body = Nokogiri::HTML.fragment(speech.govuk_delivery_email_body)
    assert_equal_ignoring_whitespace "1 January, 2011 at 12:13pm", body.css('.rss_pub_date').inner_text
  end

  test "#notification_date treats speeches differently" do
    speech = create(:speech)
    speech.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    speech.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')
    assert_equal speech.notification_date, Time.zone.parse('2011-01-01 12:13:14')
  end

  test "#notify_govuk_delivery should not send API requests for old content" do
    publication = create(:publication)

    publication.first_published_at = Time.zone.parse("2011-01-01 12:13:14")
    publication.major_change_published_at = Time.zone.now

    Whitehall.govuk_delivery_client.expects(:notify).never
    publication.publish!
  end
end
