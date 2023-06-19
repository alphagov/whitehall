require "test_helper"

class TopicalEventTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :topical_event, :name, :description

  test "should default to the 'current' state" do
    topical_event = TopicalEvent.new
    assert topical_event.current?
  end

  test "should be invalid without a name" do
    topical_event = build(:topical_event, name: nil)
    assert_not topical_event.valid?
  end

  test "should be current when created" do
    topical_event = build(:topical_event)
    assert_equal "current", topical_event.state
  end

  test "should be invalid with an unsupported state" do
    topical_event = build(:topical_event, state: "foobar")
    assert_not topical_event.valid?
  end

  test "should be invalid without a unique name" do
    existing_topical_event = create(:topical_event)
    new_topical_event = build(:topical_event, name: existing_topical_event.name)
    assert_not new_topical_event.valid?
  end

  test "should be invalid without a description" do
    topical_event = build(:topical_event, description: nil)
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
    image = create(:topical_event_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image:)
    featuring = topical_event.featuring_of(news_article)
    assert featuring
    assert_equal 0, featuring.ordering
    assert topical_event.featured?(news_article)
  end

  test "a featured news article is no longer featured when it is superseded" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    image = create(:topical_event_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image:)
    news_article.supersede!

    featuring = topical_event.reload.featuring_of(news_article)
    assert_not featuring
    assert_not topical_event.featured?(news_article)
  end

  test "#featured_editions returns featured editions by ordering" do
    topical_event = create(:topical_event)
    _alpha = topical_event.feature(edition_id: create(:edition, title: "Alpha").id, ordering: 1, alt_text: "A thing", image: create(:topical_event_featuring_image_data))
    beta = topical_event.feature(edition_id: create(:published_news_article, title: "Beta").id, ordering: 2, alt_text: "A thing", image: create(:topical_event_featuring_image_data))
    gamma = topical_event.feature(edition_id: create(:published_news_article, title: "Gamma").id, ordering: 3, alt_text: "A thing", image: create(:topical_event_featuring_image_data))
    delta = topical_event.feature(edition_id: create(:published_news_article, title: "Delta").id, ordering: 0, alt_text: "A thing", image: create(:topical_event_featuring_image_data))

    assert_equal [delta.edition, beta.edition, gamma.edition], topical_event.featured_editions
  end

  test "#featured_editions includes the newly published version of a featured edition, but not the original" do
    topical_event = create(:topical_event)
    old_version = topical_event.feature(edition_id: create(:published_news_article, title: "Gamma").id, ordering: 3, alt_text: "A thing", image: create(:topical_event_featuring_image_data)).edition

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
    supporting_org.topical_event_organisations.create!(topical_event_id: topical_event.id, lead: false)
    second_lead_org = create(:organisation)
    second_lead_org.topical_event_organisations.create!(topical_event_id: topical_event.id, lead: true, lead_ordering: 2)
    first_lead_org = create(:organisation)
    first_lead_org.topical_event_organisations.create!(topical_event_id: topical_event.id, lead: true, lead_ordering: 1)
    assert_equal topical_event.importance_ordered_organisations, [first_lead_org, second_lead_org, supporting_org]
  end

  test "#next_ordering gives a value of 0 when there are no existing features" do
    topical_event = create(:topical_event)

    assert_equal 0, topical_event.next_ordering
  end

  test "#next_ordering gives the next value when there are existing features" do
    topical_event = create(:topical_event)

    news_article_1 = create(:published_news_article)
    image_1 = create(:topical_event_featuring_image_data)
    topical_event.feature(edition_id: news_article_1.id, alt_text: "A thing", image: image_1)

    news_article_2 = create(:published_news_article)
    image_2 = create(:topical_event_featuring_image_data)
    topical_event.feature(edition_id: news_article_2.id, alt_text: "A thing", image: image_2)

    assert_equal 2, topical_event.next_ordering
  end

  test "#next_ordering gives the next value when there are existing features that have been reordered" do
    topical_event = create(:topical_event)

    news_article_1 = create(:published_news_article)
    image_1 = create(:topical_event_featuring_image_data)
    topical_event.feature(edition_id: news_article_1.id, alt_text: "A thing", image: image_1, ordering: 1)

    news_article_2 = create(:published_news_article)
    image_2 = create(:topical_event_featuring_image_data)
    topical_event.feature(edition_id: news_article_2.id, alt_text: "A thing", image: image_2, ordering: 0)

    assert_equal 2, topical_event.next_ordering
  end

  should_not_accept_footnotes_in :description

  test "supersede topical event when it ends" do
    topical_event = create(:topical_event, start_date: 1.year.ago.to_date, end_date: 1.day.ago.to_date)
    assert topical_event.archived?
    assert_equal 0, TopicalEvent.active.count
  end

  test "should include slug in search_index data" do
    topical_event = create(:topical_event, name: "mazzops 2013")
    assert_equal "mazzops-2013", topical_event.search_index["slug"]
  end

  test "should not last more than a year" do
    topical_event = build(:topical_event, start_date: 3.days.ago.to_date, end_date: (Time.zone.today + 1.year))
    assert_not topical_event.valid?
  end

  test "requires a start_date if end_date is set" do
    topical_event = build(:topical_event, end_date: (Time.zone.today + 1.year))
    assert_not topical_event.valid?
  end

  test "can be a year long" do
    topical_event = build(:topical_event, start_date: Time.zone.today, end_date: (Time.zone.today + 1.year))
    assert topical_event.valid?
  end

  test "can be a year with a day leeway" do
    topical_event = build(:topical_event, start_date: 1.day.ago.to_date, end_date: (Time.zone.today + 1.year))
    assert topical_event.valid?
  end

  test "should not end before it starts" do
    topical_event = build(:topical_event, start_date: Time.zone.today, end_date: 1.day.ago.to_date)
    assert_not topical_event.valid?
  end

  test "should be longer than a day" do
    topical_event = build(:topical_event, start_date: Time.zone.today, end_date: Time.zone.today)
    assert_not topical_event.valid?
  end

  test "for edition returns topical events related to supplied edition" do
    topical_event = create(:topical_event)
    publication = build(:publication)
    topical_event.publications << publication
    topical_event.save!
    assert_equal [topical_event], TopicalEvent.for_edition(publication.id)
  end

  test "start and end dates are considered indexable for search" do
    start_date = Date.new(2016, 1, 1)
    end_date = Date.new(2017, 1, 1)
    topical_event = create(:topical_event, start_date:, end_date:)
    rummager_payload = topical_event.search_index

    assert_equal start_date, rummager_payload["start_date"]
    assert_equal end_date, rummager_payload["end_date"]
  end

  test "#destroy also destroys 'featured topical event' associations" do
    topical_event = create(:topical_event)
    feature = create(:feature, topical_event:)
    feature_list = create(:feature_list, features: [feature])

    feature_list.reload
    assert_equal 1, feature_list.features.size

    topical_event.destroy!

    feature_list.reload
    assert_equal 0, feature_list.features.size
  end

  test "#save republishes any organisations that feature the topical event" do
    topical_event = create(:topical_event)
    organisation = create(:organisation, :with_feature_list)

    create(:feature, feature_list: organisation.feature_lists.first, topical_event:)

    Whitehall::PublishingApi.expects(:publish).with(topical_event).once
    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once

    topical_event.save!
  end

  test "public_path returns the correct path" do
    object = create(:topical_event, slug: "foo")
    assert_equal "/government/topical-events/foo", object.public_path
  end

  test "public_path returns the correct path with options" do
    object = create(:topical_event, slug: "foo")
    assert_equal "/government/topical-events/foo?cachebust=123", object.public_path(cachebust: "123")
  end

  test "public_url returns the correct path" do
    object = create(:topical_event, slug: "foo")
    assert_equal "https://www.test.gov.uk/government/topical-events/foo", object.public_url
  end

  test "public_url returns the correct path with options" do
    object = create(:topical_event, slug: "foo")
    assert_equal "https://www.test.gov.uk/government/topical-events/foo?cachebust=123", object.public_url(cachebust: "123")
  end

  test "#featurable_offsite_links returns associated offsite links that do not belong to a topical event featuring" do
    topical_event = build(:topical_event)
    offsite_link1 = build(:offsite_link)
    offsite_link2 = build(:offsite_link)
    topical_event_featuring = build(:topical_event_featuring, offsite_link: offsite_link1)

    topical_event.stubs(:offsite_links).returns([offsite_link1, offsite_link2])
    topical_event.stubs(:topical_event_featurings).returns([topical_event_featuring])

    assert_equal [offsite_link2], topical_event.featurable_offsite_links
  end

  test "#featurable_editions returns associated editions that do not belong to a topical event featuring" do
    topical_event = build(:topical_event)
    edition1 = build(:edition)
    edition2 = build(:edition)
    topical_event_featuring = build(:topical_event_featuring, edition: edition1)

    topical_event.stubs(:editions).returns([edition1, edition2])
    topical_event.stubs(:topical_event_featurings).returns([topical_event_featuring])

    assert_equal [edition2], topical_event.featurable_editions
  end

  test "rejects SVG logo uploads" do
    svg_logo = File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))
    topical_event = build(:topical_event, logo: svg_logo)

    assert_not topical_event.valid?
    assert_equal topical_event.errors.first.full_message, "Logo is not of an allowed type"
  end
end
