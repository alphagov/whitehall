require 'test_helper'

class Whitehall::GovUkDelivery::EmailSignupDescriptionTest < ActiveSupport::TestCase
  include Whitehall::GovUkDelivery

  test 'generates an appropriate sentence for a publication feed url that has all possible query params' do
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

    assert_equal "corporate reports related to The Cabinet Office, Arts and culture and Afghanistan which are command or act papers", EmailSignupDescription.new(feed_url).text
  end

  test 'generates an appropriate sentence for the publications feed url' do
    feed_url = feed_url_for(document_type: "publications")

    assert_equal "publications", EmailSignupDescription.new(feed_url).text
  end

  test "generates an appropriate sentence for an organisation's documents feed url" do
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    feed_url = feed_url_for(departments: ["the-cabinet-office"])

    assert_equal "documents related to The Cabinet Office", EmailSignupDescription.new(feed_url).text
  end

  test 'generates an appropriate sentence for an announcements feed url' do
    create(:topic, slug: 'arts-and-culture', name: 'Arts and culture')
    create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    create(:world_location, slug: 'afghanistan', name: 'Afghanistan')

    feed_url = feed_url_for(
      document_type: "announcements",
      topics: ["arts-and-culture"],
      departments: ["the-cabinet-office"],
      world_locations: ["afghanistan"]
    )

    assert_equal "announcements related to The Cabinet Office, Arts and culture and Afghanistan", EmailSignupDescription.new(feed_url).text
  end

  test 'uses the announcement_filter_option when given' do
    feed_url = feed_url_for(document_type: "announcements", announcement_filter_option: "fatality-notices")
    assert_equal "fatality notices", EmailSignupDescription.new(feed_url).text
  end

  test 'uses the organisation name for organisation feeds' do
    organisation = create(:ministerial_department, :with_published_edition, name: 'The Cabinet Office')
    feed_url = generic_url_maker.organisation_url(organisation)

    assert_equal organisation.name, EmailSignupDescription.new(feed_url).text
  end

  test 'uses the policy name for a policy feed' do
    policy = create(:published_policy, title: 'A policy')
    feed_url = generic_url_maker.activity_policy_url(policy.slug)

    assert_equal policy.title, EmailSignupDescription.new(feed_url).text
  end

  test 'uses the topic name for a topic feed' do
    topic = create(:topic, name: 'A topic')
    feed_url = generic_url_maker.topic_url(topic)

    assert_equal topic.name, EmailSignupDescription.new(feed_url).text
  end

  test 'uses the topical event name for a topical event feed' do
    topical_event = create(:topical_event, name: 'A topical event')
    feed_url = generic_url_maker.topical_event_url(topical_event)

    assert_equal topical_event.name, EmailSignupDescription.new(feed_url).text
  end

  test 'uses the world location name for a world location feed' do
    world_location = create(:world_location, name: 'A world location')
    feed_url = generic_url_maker.world_location_url(world_location)

    assert_equal world_location.name, EmailSignupDescription.new(feed_url).text
  end

  test 'uses the person name for a person feed' do
    person = create(:person, forename: 'A', surname: 'Person')
    feed_url = generic_url_maker.person_url(person)

    assert_equal person.name, EmailSignupDescription.new(feed_url).text
  end

  test 'uses the role name for a role feed' do
    role = create(:role, name: 'A role')
    feed_url = generic_url_maker.ministerial_role_url(role)

    assert_equal role.name, EmailSignupDescription.new(feed_url).text
  end

  test 'appends "which are relevant to local government" when relevant_to_local_government is truthy' do
    feed_url = feed_url_for( document_type: "publications", relevant_to_local_government: '1')

    assert_equal "publications which are relevant to local government", EmailSignupDescription.new(feed_url).text
  end

  test 'appends "which are command papers and are relevant to local government" when relevant_to_local_government is truthy and official_document_status is present' do
    feed_url = feed_url_for( document_type: "publications", official_document_status: "command_papers_only", relevant_to_local_government: '1')

    assert_equal "publications which are command papers and are relevant to local government", EmailSignupDescription.new(feed_url).text
  end

private

  def feed_url_for(params)
    Whitehall::FeedUrlBuilder.new(params).url
  end

  def generic_url_maker
    Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: :atom)
  end
end
