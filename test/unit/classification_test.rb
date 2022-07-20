require "test_helper"

class ClassificationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :description

  test "should default to the 'current' state" do
    topical_event = Classification.new
    assert topical_event.current?
  end

  test "should be invalid without a name" do
    topical_event = build(:classification, name: nil)
    assert_not topical_event.valid?
  end

  test "should be current when created" do
    topical_event = build(:classification)
    assert_equal "current", topical_event.state
  end

  test "should be invalid with an unsupported state" do
    topical_event = build(:classification, state: "foobar")
    assert_not topical_event.valid?
  end

  test "should be invalid without a unique name" do
    existing_topical_event = create(:classification)
    new_topical_event = build(:classification, name: existing_topical_event.name)
    assert_not new_topical_event.valid?
  end

  test "should be invalid without a description" do
    topical_event = build(:classification, description: nil)
    assert_not topical_event.valid?
  end

  test "#latest should return specified number of associated publised editions in reverse chronological order" do
    topical_event = create(:topical_event)
    other_topical_event = create(:topical_event)
    expected_order = [
      create(:published_publication, topical_events: [topical_event], first_published_at: 1.day.ago),
      create(:published_news_article, topical_events: [topical_event], first_published_at: 1.week.ago),
      create(:published_publication, topical_events: [topical_event], first_published_at: 2.weeks.ago),
      create(:published_speech, topical_events: [topical_event], first_published_at: 3.weeks.ago),
      create(:published_publication, topical_events: [topical_event], first_published_at: 4.weeks.ago),
    ]
    create(:draft_speech, topical_events: [topical_event], first_published_at: 2.days.ago)
    create(:published_speech, topical_events: [other_topical_event], first_published_at: 2.days.ago)

    assert_equal expected_order, topical_event.latest(10)
  end

  test "an unfeatured news article is not featured" do
    topical_event = create(:topical_event)
    news_article = build(:news_article)
    assert_not topical_event.featured?(news_article)
  end

  test "a featured news article is featured" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    image = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image: image)
    featuring = topical_event.featuring_of(news_article)
    assert featuring
    assert_equal 0, featuring.ordering
    assert topical_event.featured?(news_article)
  end

  test "a featured news article is no longer featured when it is superseded" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    image = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image: image)
    news_article.supersede!

    featuring = topical_event.reload.featuring_of(news_article)
    assert_not featuring
    assert_not topical_event.featured?(news_article)
  end

  test "#featured_editions returns featured editions by ordering" do
    topical_event = create(:topical_event)
    _alpha = topical_event.feature(edition_id: create(:edition, title: "Alpha").id, ordering: 1, alt_text: "A thing", image: create(:classification_featuring_image_data))
    beta = topical_event.feature(edition_id: create(:published_news_article, title: "Beta").id, ordering: 2, alt_text: "A thing", image: create(:classification_featuring_image_data))
    gamma = topical_event.feature(edition_id: create(:published_news_article, title: "Gamma").id, ordering: 3, alt_text: "A thing", image: create(:classification_featuring_image_data))
    delta = topical_event.feature(edition_id: create(:published_news_article, title: "Delta").id, ordering: 0, alt_text: "A thing", image: create(:classification_featuring_image_data))

    assert_equal [delta.edition, beta.edition, gamma.edition], topical_event.featured_editions
  end

  test "#featured_editions includes the newly published version of a featured edition, but not the original" do
    topical_event = create(:topical_event)
    old_version = topical_event.feature(edition_id: create(:published_news_article, title: "Gamma").id, ordering: 3, alt_text: "A thing", image: create(:classification_featuring_image_data)).edition

    editor = create(:departmental_editor)
    new_version = old_version.create_draft(editor)
    new_version.change_note = "New stuffs!"
    new_version.save!
    force_publish(new_version)

    assert_not topical_event.featured_editions.include?(old_version)
    assert topical_event.featured_editions.include?(new_version)
  end

  test "#importance_ordered_organisations" do
    topical_event = create(:topical_event)
    supporting_org = create(:organisation)
    supporting_org.organisation_classifications.create!(classification_id: topical_event.id, lead: false)
    second_lead_org = create(:organisation)
    second_lead_org.organisation_classifications.create!(classification_id: topical_event.id, lead: true, lead_ordering: 2)
    first_lead_org = create(:organisation)
    first_lead_org.organisation_classifications.create!(classification_id: topical_event.id, lead: true, lead_ordering: 1)
    assert_equal topical_event.importance_ordered_organisations, [first_lead_org, second_lead_org, supporting_org]
  end

  test "#next_ordering gives a value of 0 when there are no existing features" do
    topical_event = create(:topical_event)

    assert_equal 0, topical_event.next_ordering
  end

  test "#next_ordering gives the next value when there are existing features" do
    topical_event = create(:topical_event)

    news_article_1 = create(:published_news_article)
    image_1 = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article_1.id, alt_text: "A thing", image: image_1)

    news_article_2 = create(:published_news_article)
    image_2 = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article_2.id, alt_text: "A thing", image: image_2)

    assert_equal 2, topical_event.next_ordering
  end

  test "#next_ordering gives the next value when there are existing features that have been reordered" do
    topical_event = create(:topical_event)

    news_article_1 = create(:published_news_article)
    image_1 = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article_1.id, alt_text: "A thing", image: image_1, ordering: 1)

    news_article_2 = create(:published_news_article)
    image_2 = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article_2.id, alt_text: "A thing", image: image_2, ordering: 0)

    assert_equal 2, topical_event.next_ordering
  end

  should_not_accept_footnotes_in :description
end
