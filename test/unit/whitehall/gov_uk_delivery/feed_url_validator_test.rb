require 'test_helper'

class Whitehall::GovUkDelivery::FeedUrlValidatorTest < ActiveSupport::TestCase
  include Whitehall::GovUkDelivery

  test 'handles badly formatted feed urls' do
    refute FeedUrlValidator.new('https://www.glue=latvia').valid?
    refute FeedUrlValidator.new('https://www.gov.uk/government]').valid?
  end

  test 'validates and describes a base publication filter feed url' do
    feed_url  = feed_url_for(document_type: "publications")
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal "publications", validator.description
  end

  test 'validates and describes a publication filter feed url with filter options' do
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
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal "corporate reports related to The Cabinet Office, Arts and culture and Afghanistan which are command or act papers", validator.description
  end

  test 'validates and describes an announcements filter feed url' do
    create(:topic, slug: 'arts-and-culture', name: 'Arts and culture')
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    create(:world_location, slug: 'afghanistan', name: 'Afghanistan')

    feed_url = feed_url_for(
      document_type: "announcements",
      topics: ["arts-and-culture"],
      departments: ["the-cabinet-office"],
      world_locations: ["afghanistan"]
    )
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal "announcements related to The Cabinet Office, Arts and culture and Afghanistan", validator.description
  end

  test 'uses the announcement_filter_option when given' do
    feed_url = feed_url_for(document_type: "announcements", announcement_filter_option: "fatality-notices")
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal "fatality notices", validator.description
  end

  test 'validates and describes an organisation feed url' do
    organisation = create(:ministerial_department, :with_published_edition)
    feed_url  = generic_url_maker.organisation_url(organisation)
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal organisation.name, validator.description
  end

  test 'validates and describes a policy feed url' do
    policy    = create(:published_policy)
    feed_url  = generic_url_maker.activity_policy_url(policy.slug)
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal policy.title, validator.description
  end

  test 'validates and describes a topic feed url' do
    topic     = create(:topic)
    feed_url  = generic_url_maker.topic_url(topic)
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal topic.name, validator.description
  end

  test 'validates and describes a topical event feed url' do
    topical_event = create(:topical_event)
    feed_url      = generic_url_maker.topical_event_url(topical_event)
    validator     = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal topical_event.name, validator.description
  end

  test 'validates and describes a world location feed url' do
    world_location = create(:world_location)
    feed_url       = generic_url_maker.world_location_url(world_location)
    validator      = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal world_location.name, validator.description
  end

  test 'validates and describes a person feed url' do
    person = create(:person)
    feed_url = generic_url_maker.person_url(person)
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal person.name, validator.description
  end

  test 'validates and describes a role feed url' do
    role = create(:role)
    feed_url = generic_url_maker.ministerial_role_url(role)
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal role.name, validator.description
  end

  test 'does not validate a feed url for another host' do
    refute FeedUrlValidator.new('http://somewhere-else.com/publications.atom').valid?
  end

  test 'does not validate a feed url with an incorrect protocol' do
    refute FeedUrlValidator.new("ftp://#{Whitehall.public_host}/government/publications.atom").valid?
  end

  test 'does not validate a feed url with an unrecognised path' do
    refute FeedUrlValidator.new("#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/does-not-exist.atom").valid?
  end

  test 'does not validate a feed url with a dodgy format' do
    refute FeedUrlValidator.new("#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications.foo").valid?
  end

  test 'does not validate a feed url when the resource does not exist' do
    feed_url = generic_url_maker.topic_url('non-existant-slug')

    refute FeedUrlValidator.new(feed_url).valid?
  end

  test 'does not validate a feed url when the policy does not exist' do
    feed_url = generic_url_maker.activity_policy_url('non-existant-slug')

    refute FeedUrlValidator.new(feed_url).valid?
  end

  test 'does not validate a feed url for an unpublished policy' do
    feed_url = generic_url_maker.activity_policy_url(create(:draft_policy).slug)

    refute FeedUrlValidator.new(feed_url).valid?
  end

  test 'does not validate a feed url with additional parameters' do
    feed_url = generic_url_maker.ministerial_role_url(create(:role), extra_param: 'hax')

    refute FeedUrlValidator.new(feed_url).valid?
  end

  test 'does not validate a feed url for filtered documents with invalid filter options' do
    feed_url   = generic_url_maker.publications_url(extra_param: 'boo')
    validator  = FeedUrlValidator.new(feed_url)

    refute validator.valid?
  end

  test 'does not validate a feed url for filtered documents when one of the filter options refers to a non-existant resource' do
    feed_url = feed_url_for(document_type: "publications", departments: ["does-not-exist"])
    validator = FeedUrlValidator.new(feed_url)

    refute validator.valid?
  end

  test '#description does not fall over when the feed is bad' do
    assert_nil FeedUrlValidator.new('http://bad/feed').description
  end

  test 'appends "which are relevant to local government" when relevant_to_local_government is truthy' do
    feed_url  = feed_url_for(document_type: "publications", relevant_to_local_government: '1')
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal "publications which are relevant to local government", validator.description
  end

  test 'appends "which are command papers and are relevant to local government" when relevant_to_local_government is truthy and official_document_status is present' do
    feed_url = feed_url_for(document_type: "publications", official_document_status: "command_papers_only", relevant_to_local_government: '1')
    validator = FeedUrlValidator.new(feed_url)

    assert validator.valid?
    assert_equal "publications which are command papers and are relevant to local government", validator.description
  end

private

  def feed_url_for(params)
    Whitehall::FeedUrlBuilder.new(params).url
  end

  def generic_url_maker
    Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: :atom)
  end
end
