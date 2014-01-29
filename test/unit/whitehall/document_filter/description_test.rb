require 'test_helper'

class Whitehall::DocumentFilter::DescriptionTest < ActiveSupport::TestCase

  test 'With a publications feed url and all possible query params given, it generates a nice sentance' do
    create(:topic, slug: 'arts-and-culture', name: 'Arts and culture')
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    create(:world_location, slug: 'afghanistan', name: 'Afghanistan')

    feed_url = feed_url_for(
      document_type: "publications",
      publication_filter_option: "corporate-reports",
      topics: ["arts-and-culture"],
      departments: ["the-cabinet-office"],
      official_document_status: "command_and_act_papers",
      world_locations: ["afghanistan"]
    )

    assert_equal "corporate reports related to The Cabinet Office, Arts and culture and Afghanistan which are command or act papers", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'with a publication with no publication_filter_option and no other params, it makes a nice sentence' do
    feed_url = feed_url_for(
      document_type: "publications"
    )

    assert_equal "publications", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'it calls untyped feeds documents' do
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    feed_url = feed_url_for(
      departments: ["the-cabinet-office"]
    )
    assert_equal "documents related to The Cabinet Office", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'it makes nice sentences for announcement feeds without an announcement_filter_option' do
    create(:topic, slug: 'arts-and-culture', name: 'Arts and culture')
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    create(:world_location, slug: 'afghanistan', name: 'Afghanistan')

    feed_url = feed_url_for(
      document_type: "announcements",
      topics: ["arts-and-culture"],
      departments: ["the-cabinet-office"],
      world_locations: ["afghanistan"]
    )
    assert_equal "announcements related to The Cabinet Office, Arts and culture and Afghanistan", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses announcement_filter_option when given' do
    feed_url = feed_url_for(
      document_type: "announcements",
      announcement_filter_option: "fatality-notices"
    )
    assert_equal "fatality notices", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the organisation name for organisation feeds' do
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    feed_url = generic_url_maker.organisation_url('the-cabinet-office')
    assert_equal "The Cabinet Office", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the policy name for policy feeds' do
    create(:published_policy, title: 'A policy')
    feed_url = generic_url_maker.activity_policy_url('a-policy')
    assert_equal "A policy", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the topic name for topic feeds' do
    create(:topic, name: 'A topic')
    feed_url = generic_url_maker.topic_url('a-topic')
    assert_equal "A topic", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the topical event name for topical event feeds' do
    create(:topical_event, name: 'A topical event')
    feed_url = generic_url_maker.topical_event_url('a-topical-event')
    assert_equal "A topical event", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the world location name for world location feeds' do
    create(:world_location, name: 'A world location')
    feed_url = generic_url_maker.world_location_url('a-world-location')
    assert_equal "A world location", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the person\'s name for person feeds' do
    create(:person, forename: 'A', surname: 'Person')
    feed_url = generic_url_maker.person_url('a-person')
    assert_equal "A Person", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

  test 'uses the role name for role feeds' do
    create(:role, name: 'A role')
    feed_url = generic_url_maker.ministerial_role_url('a-role')
    assert_equal "A role", Whitehall::DocumentFilter::Description.new(feed_url).text
  end

private

  def feed_url_for(params)
    Whitehall::FeedUrlBuilder.new(params).url
  end

  def generic_url_maker
    Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: :atom)
  end
end
