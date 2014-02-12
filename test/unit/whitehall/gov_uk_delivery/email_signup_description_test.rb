require 'test_helper'

class Whitehall::GovUkDelivery::EmailSignupDescriptionTest < ActiveSupport::TestCase
  include Whitehall::GovUkDelivery

  test 'validates and describes the base document feed' do
    validator = EmailSignupDescription.new(generic_url_maker.atom_feed_url)

    assert validator.valid?
    assert_equal 'documents', validator.text
  end

  test 'validates and describes a base publication filter feed url' do
    feed_url  = feed_url_for(document_type: "publications")
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal "publications", validator.text
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
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal "corporate reports related to The Cabinet Office, Arts and culture and Afghanistan which are command or act papers", validator.text
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
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal "announcements related to The Cabinet Office, Arts and culture and Afghanistan", validator.text
  end

  test 'uses the announcement_filter_option when given' do
    feed_url = feed_url_for(document_type: "announcements", announcement_filter_option: "fatality-notices")
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal "fatality notices", validator.text
  end

  test 'validates and describes an organisation feed url' do
    organisation = create(:ministerial_department, :with_published_edition)
    feed_url  = generic_url_maker.organisation_url(organisation)
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal organisation.name, validator.text
  end

  test 'validates and describes a policy feed url' do
    policy    = create(:published_policy)
    feed_url  = generic_url_maker.activity_policy_url(policy.slug)
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal policy.title, validator.text
  end

  test 'validates and describes a topic feed url' do
    topic     = create(:topic)
    feed_url  = generic_url_maker.topic_url(topic)
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal topic.name, validator.text
  end

  test 'validates and describes a topical event feed url' do
    topical_event = create(:topical_event)
    feed_url      = generic_url_maker.topical_event_url(topical_event)
    validator     = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal topical_event.name, validator.text
  end

  test 'validates and describes a world location feed url' do
    world_location = create(:world_location)
    feed_url       = generic_url_maker.world_location_url(world_location)
    validator      = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal world_location.name, validator.text
  end

  test 'validates and describes a person feed url' do
    person = create(:person)
    feed_url = generic_url_maker.person_url(person)
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal person.name, validator.text
  end

  test 'validates and describes a role feed url' do
    role = create(:role)
    feed_url = generic_url_maker.ministerial_role_url(role)
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal role.name, validator.text
  end

  test 'does not validate a feed url for another host' do
    refute EmailSignupDescription.new('http://somewhere-else.com//publications.atom').valid?
  end

  test 'does not validate a feed url with an incorrect protocol' do
    refute EmailSignupDescription.new("ftp://#{Whitehall.public_host}/government/publications.atom").valid?
  end

  test 'does not validate a feed url with an unrecognised path' do
    refute EmailSignupDescription.new("#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/does-not-exist.atom").valid?
  end

  test 'does not validate a feed url when the resource does not exist' do
    feed_url = generic_url_maker.topic_url('non-existant-slug')

    refute EmailSignupDescription.new(feed_url).valid?
  end

  test 'does not validate a feed url when the policy does not exist' do
    feed_url = generic_url_maker.activity_policy_url('non-existant-slug')

    refute EmailSignupDescription.new(feed_url).valid?
  end

  test 'does not validate a feed url for an unpublished policy' do
    feed_url = generic_url_maker.activity_policy_url(create(:draft_policy).slug)

    refute EmailSignupDescription.new(feed_url).valid?
  end

  test 'does not validate a feed url with additional parameters' do
    feed_url = generic_url_maker.ministerial_role_url(create(:role), extra_param: 'hax')

    refute EmailSignupDescription.new(feed_url).valid?
  end

  test 'does not validate a feed url for filtered documents with invalid filter options' do
    feed_url   = generic_url_maker.publications_url(extra_param: 'boo')
    validator  = EmailSignupDescription.new(feed_url)

    refute validator.valid?
  end

  test 'appends "which are relevant to local government" when relevant_to_local_government is truthy' do
    feed_url  = feed_url_for(document_type: "publications", relevant_to_local_government: '1')
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal "publications which are relevant to local government", validator.text
  end

  test 'appends which are command papers and are relevant to local government when relevant_to_local_government is truthy and official_document_status is present' do
    feed_url = feed_url_for(document_type: "publications", official_document_status: "command_papers_only", relevant_to_local_government: '1')
    validator = EmailSignupDescription.new(feed_url)

    assert validator.valid?
    assert_equal "publications which are command papers and are relevant to local government", validator.text
  end

private

  def feed_url_for(params)
    Whitehall::FeedUrlBuilder.new(params).url
  end

  def generic_url_maker
    Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: :atom)
  end
end
