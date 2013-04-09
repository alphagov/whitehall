# encoding: utf-8

require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
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

  test '#notify_govuk_delivery sends a notification via the govuk delivery client when there are topics' do
    policy = create(:policy, topics: [create(:topic)])
    policy.stubs(:govuk_delivery_email_body).returns('email body')
    Whitehall.govuk_delivery_client.expects(:notify).with(policy.govuk_delivery_tags, policy.title, 'email body')

    policy.notify_govuk_delivery
  end

  test '#notify_govuk_delivery does nothing if the change is minor' do
    policy = create(:policy, topics: [create(:topic)], minor_change: true)
    Whitehall.govuk_delivery_client.expects(:notify).never

    policy.notify_govuk_delivery
  end

  test '#notify_govuk_delivery swallows errors from the API' do
    policy = create(:policy, topics: [create(:topic)])
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 500)

    assert_nothing_raised { policy.notify_govuk_delivery }
  end

  test "should notify govuk_delivery on publishing policies" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    policy.expects(:notify_govuk_delivery).once
    policy.publish!
  end

  test "should notify govuk_delivery on publishing news articles" do
    news_article = create(:news_article)
    news_article.first_published_at = Time.zone.now
    news_article.major_change_published_at = Time.zone.now


    news_article.expects(:notify_govuk_delivery).once
    news_article.publish!
  end

  test "should notify govuk_delivery on publishing publications" do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    publication.expects(:notify_govuk_delivery).once
    publication.publish!
  end

  test "should link to full URL in email" do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    assert_match /#{Whitehall.public_host}/, publication.govuk_delivery_email_body
  end
end
