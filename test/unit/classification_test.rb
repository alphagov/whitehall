require 'test_helper'

class ClassificationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :description

  test "should default to the 'current' state" do
    topic = Classification.new
    assert topic.current?
  end

  test 'should be invalid without a name' do
    topic = build(:classification, name: nil)
    refute topic.valid?
  end

  test "should be current when created" do
    topic = build(:classification)
    assert_equal "current", topic.state
  end

  test "should be invalid with an unsupported state" do
    topic = build(:classification, state: "foobar")
    refute topic.valid?
  end

  test 'should be invalid without a unique name' do
    existing_topic = create(:classification)
    new_topic = build(:classification, name: existing_topic.name)
    refute new_topic.valid?
  end

  test 'should be invalid without a description' do
    topic = build(:classification, description: nil)
    refute topic.valid?
  end

  test "#latest should return specified number of associated publised editions except world location news articles in reverse chronological order" do
    topic = create(:topic)
    other_topic = create(:topic)
    expected_order = [
      create(:published_policy, topics: [topic], first_published_at: 1.day.ago),
      create(:published_news_article, topics: [topic], first_published_at: 1.week.ago),
      create(:published_publication, topics: [topic], first_published_at: 2.weeks.ago),
      create(:published_speech, topics: [topic], first_published_at: 3.weeks.ago),
      create(:published_policy, topics: [topic], first_published_at: 4.weeks.ago)
    ]
    create(:draft_speech, topics: [topic], first_published_at: 2.days.ago)
    create(:published_speech, topics: [other_topic], first_published_at: 2.days.ago)
    create(:published_world_location_news_article, topics: [topic], first_published_at: 2.days.ago)

    assert_equal expected_order, topic.latest(10)
    assert_equal expected_order[0..1], topic.latest(2)
  end

  test "an unfeatured news article is not featured" do
    topical_event = create(:topical_event)
    news_article = build(:news_article)
    refute topical_event.featured?(news_article)
  end

  test "a featured news article is featured" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    image = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image: image)
    featuring = topical_event.featuring_of(news_article)
    assert featuring
    assert_equal 1, featuring.ordering
    assert topical_event.featured?(news_article)
  end

  test "a featured news article is no longer featured when it is archived" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    image = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image: image)
    news_article.archive!

    featuring = topical_event.reload.featuring_of(news_article)
    refute featuring
    refute topical_event.featured?(news_article)
  end

  test '#featured_editions returns featured editions by ordering' do
    topic = create(:topic)
    alpha = topic.feature(edition_id: create(:edition, title: "Alpha").id, ordering: 1, alt_text: 'A thing', image: create(:classification_featuring_image_data))
    beta  = topic.feature(edition_id: create(:published_news_article, title: "Beta").id, ordering: 2, alt_text: 'A thing', image: create(:classification_featuring_image_data))
    gamma = topic.feature(edition_id: create(:published_news_article, title: "Gamma").id, ordering: 3, alt_text: 'A thing', image: create(:classification_featuring_image_data))
    delta = topic.feature(edition_id: create(:published_news_article, title: "Delta").id, ordering: 0, alt_text: 'A thing', image: create(:classification_featuring_image_data))

    assert_equal [delta.edition, beta.edition, gamma.edition], topic.featured_editions
  end

  test '#featured_editions includes the newly published version of a featured edition, but not the original' do
    topical_event = create(:topical_event)
    old_version = topical_event.feature(edition_id: create(:published_news_article, title: "Gamma").id, ordering: 3, alt_text: 'A thing', image: create(:classification_featuring_image_data)).edition

    editor = create(:departmental_editor)
    new_version = old_version.create_draft(editor)
    new_version.change_note = 'New stuffs!'
    new_version.save
    force_publish(new_version)

    refute topical_event.featured_editions.include?(old_version)
    assert topical_event.featured_editions.include?(new_version)
  end
end
