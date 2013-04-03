require "test_helper"


class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
  test '#govuk_delivery_tags returns an empty array if the edition has no topics' do
    assert_equal [], build(:policy).govuk_delivery_tags
  end

  test '#govuk_delivery_tags returns an atom feed url for the organisation and a topic' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation])

    assert_equal ["https://www.preview.alphagov.co.uk/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"],
      edition.govuk_delivery_tags
  end

  test '#govuk_delivery_tags returns an atom feed url for each topic/organisation combination' do
    topic1 = create(:topic)
    topic2 = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic1, topic2], organisations: [organisation])

    assert_equal ["https://www.preview.alphagov.co.uk/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic1.slug}",
                  "https://www.preview.alphagov.co.uk/government/policies.atom?departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic2.slug}"],
      edition.govuk_delivery_tags
  end

  test '#govuk_delivery_tags includes relevant to local param if edition is relevant' do
    topic = create(:topic)
    organisation = create(:ministerial_department)
    edition = create(:policy, topics: [topic], organisations: [organisation], relevant_to_local_government: true)

    assert_equal ["https://www.preview.alphagov.co.uk/government/policies.atom?departments%5B%5D=#{organisation.slug}&relevant_to_local_government=true&topics%5B%5D=#{topic.slug}"],
      edition.govuk_delivery_tags
  end

  test '#govuk_delivery_tags generates urls for publications with the publication filter option' do
    topic = create(:topic)
    policy = create(:published_policy, topics: [topic])
    organisation = create(:ministerial_department)
    publication = create(:publication, organisations: [organisation], related_documents: [policy.document])

    assert_equal ["https://www.preview.alphagov.co.uk/government/publications.atom?departments%5B%5D=#{organisation.slug}&publication_filter_option=policy-papers&topics%5B%5D=#{topic.slug}"],
      publication.govuk_delivery_tags
  end

  test '#govuk_delivery_tags generates urls for news articles with the announcement type option' do
    topic = create(:topic)
    policy = create(:published_policy, topics: [topic])
    organisation = create(:ministerial_department)
    publication = create(:news_article, organisations: [organisation], related_documents: [policy.document])

    assert_equal ["https://www.preview.alphagov.co.uk/government/announcements.atom?announcement_type_option=press-releases&departments%5B%5D=#{organisation.slug}&topics%5B%5D=#{topic.slug}"],
      publication.govuk_delivery_tags
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
end
