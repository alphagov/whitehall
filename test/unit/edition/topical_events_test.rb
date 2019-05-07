require 'test_helper'

class Edition::TopicalEventsTest < ActiveSupport::TestCase
  test "includes PublishesToPublishingApi" do
    topical_event = TopicalEvent.new
    assert topical_event.is_a?(PublishesToPublishingApi)
  end

  test "#destroy should also remove the classification memebership relationship" do
    topical_event = create(:topical_event)
    edition = create(:published_news_article, topical_events: [topical_event])
    relation = edition.classification_memberships.first
    edition.destroy
    assert_not ClassificationMembership.find_by(id: relation.id)
  end

  test "new edition of document that is a member of a topical event should remain a member of that topical event" do
    topical_event = create(:topical_event)
    edition = create(:published_news_article, topical_events: [topical_event])

    new_edition = edition.create_draft(create(:writer))
    new_edition.change_note = 'change-note'
    force_publish(new_edition)

    assert_equal topical_event, new_edition.topical_events.first
  end

  test "#destroy should also remove the classification featuring relationship" do
    topical_event = create(:topical_event)
    edition = create(:published_news_article)
    _rel = topical_event.feature(edition_id: edition.id, alt_text: 'Woooo', image: create(:classification_featuring_image_data))
    relation = edition.classification_featurings.first
    edition.destroy
    assert_not ClassificationFeaturing.find_by(id: relation.id)
  end

  test "new edition of document featured in topical event should remain featured in that topic event with image, alt text and ordering" do
    featured_image = create(:classification_featuring_image_data)
    topical_event = create(:topical_event)
    edition = create(:published_news_article)
    topical_event.feature(edition_id: edition.id, image: featured_image, alt_text: "alt-text", ordering: 12)

    new_edition = edition.create_draft(create(:writer))
    new_edition.change_note = 'change-note'
    force_publish(new_edition)

    featuring = new_edition.classification_featurings.first
    assert featuring.persisted?
    assert_equal featured_image, featuring.image
    assert_equal "alt-text", featuring.alt_text
    assert_equal 12, featuring.ordering
    assert_equal topical_event, featuring.classification
  end
end
