require 'test_helper'

class EmailSignupTest < ActiveSupport::TestCase
  test 'the list of valid_topics_by_type exposes topics and topical events' do
    assert_equal [:topic, :topical_event], EmailSignup.valid_topics_by_type.keys.sort
  end

  test 'the list of valid_topics_by_type only includes topics with published policies in the list of topics' do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    policy  = create(:published_policy)
    topic_1.editions << policy

    topics_by_type = EmailSignup.valid_topics_by_type
    assert topics_by_type[:topic].include?(topic_1)
    refute topics_by_type[:topic].include?(topic_2)
    refute topics_by_type[:topical_event].include?(topic_1)
    refute topics_by_type[:topical_event].include?(topic_2)
  end

  test 'the list of valid_topics_by_type includes all topical events even if they have no published policies in the list of topical event' do
    topical_event_1 = create(:topical_event, :active)
    topical_event_2 = create(:topical_event, :active)
    policy  = create(:published_policy)
    topical_event_1.editions << policy

    topics_by_type = EmailSignup.valid_topics_by_type
    assert topics_by_type[:topical_event].include?(topical_event_1)
    assert topics_by_type[:topical_event].include?(topical_event_2)
    refute topics_by_type[:topic].include?(topical_event_1)
    refute topics_by_type[:topic].include?(topical_event_2)
  end

  test 'the list of valid_organisations_by_type is split into ministerial and other' do
    assert_equal [:ministerial, :other], EmailSignup.valid_organisations_by_type.keys
  end

  test 'the ministerial valid_organisations_by_type only includes live orgs of type "Ministerial department"' do
    live_ministerial_dept = create(:organisation, govuk_status: 'live', organisation_type: OrganisationType.ministerial_department)
    live_other_dept = create(:organisation, govuk_status: 'live', organisation_type: OrganisationType.other)
    not_live_ministerial_dept = create(:organisation, govuk_status: 'joining', organisation_type: OrganisationType.ministerial_department)

    valid_ministerial_orgs = EmailSignup.valid_organisations_by_type[:ministerial]
    assert valid_ministerial_orgs.include?(live_ministerial_dept)
    refute valid_ministerial_orgs.include?(live_other_dept)
    refute valid_ministerial_orgs.include?(not_live_ministerial_dept)
  end

  test 'the ministerial valid_organisations_by_type includes live orgs that are not of type "Ministerial department" or "Sub-organisation"' do
    live_ministerial_dept = create(:organisation, govuk_status: 'live', organisation_type: OrganisationType.ministerial_department)
    live_other_dept = create(:organisation, govuk_status: 'live', organisation_type: OrganisationType.other)
    not_live_other_dept = create(:organisation, govuk_status: 'joining', organisation_type: OrganisationType.other)
    live_sub_org = create(:organisation, govuk_status: 'joining', organisation_type: OrganisationType.sub_organisation, parent_organisations: [live_ministerial_dept])

    valid_other_orgs = EmailSignup.valid_organisations_by_type[:other]
    refute valid_other_orgs.include?(live_ministerial_dept)
    assert valid_other_orgs.include?(live_other_dept)
    refute valid_other_orgs.include?(not_live_other_dept)
    refute valid_other_orgs.include?(live_sub_org)
  end

  test 'the list of valid_document_types_by_type is split into publication_type, announcement_type, and policy_type' do
    assert_equal [:publication_type, :announcement_type, :policy_type], EmailSignup.valid_document_types_by_type.keys
  end

  test 'the list of valid_document_types_by_type includes an "all" option as the first option for each subtype' do
    assert_equal 'all', EmailSignup.valid_document_types_by_type[:publication_type].first.slug
    assert_equal 'all', EmailSignup.valid_document_types_by_type[:announcement_type].first.slug
    assert_equal 'all', EmailSignup.valid_document_types_by_type[:policy_type].first.slug
  end

  test 'the list of publication_type options in valid_document_types_by_type includes all PublicationFilterOptions' do
    assert_same_elements Whitehall::PublicationFilterOption.all, EmailSignup.valid_document_types_by_type[:publication_type][1..-1]
  end

  test 'the list of announcement_type options in valid_document_types_by_type includes all AnnouncementFilterOtptions' do
    assert_same_elements Whitehall::AnnouncementFilterOption.all, EmailSignup.valid_document_types_by_type[:announcement_type][1..-1]
  end

  test 'the list of policy_type options in valid_document_types_by_type is empty (apart from the "all" option)' do
    assert_same_elements [], EmailSignup.valid_document_types_by_type[:policy_type][1..-1]
  end

  test 'the list of valid_document_type_slugs uses the slug of the option and prefixes it with the sub_type' do
    EmailSignup.stubs(:valid_document_types_by_type).returns({foo: [stub(slug: 'bar'), stub(slug: 'baz')], qux: [stub(slug: 'quux')]})

    assert_equal ['foo_bar', 'foo_baz', 'qux_quux'], EmailSignup.valid_document_type_slugs - ['all']
  end

  test 'setting alerts with a hash constructs a single alert from that hash' do
    h = {foo: 'bar'}
    e = EmailSignup.new
    EmailSignup::Alert.expects(:new).with(h).returns :an_alert
    e.alerts = h
    assert_equal [:an_alert], e.alerts
  end

  test 'setting alerts with a single Alert sets the alerts array to contain that' do
    a = EmailSignup::Alert.new
    e = EmailSignup.new
    e.alerts = a
    assert_equal [a], e.alerts
  end

  test 'setting alerts with an array of hashes constructs an alert from each hash' do
    alert_creation = sequence('alert-creation')
    h1 = {foo: 'bar'}
    h2 = {foo: 'bar'}
    e = EmailSignup.new
    EmailSignup::Alert.expects(:new).with(h2).in_sequence(alert_creation).returns :h2_alert
    EmailSignup::Alert.expects(:new).with(h1).in_sequence(alert_creation).returns :h1_alert
    e.alerts = [h2, h1]
    assert_equal [:h2_alert, :h1_alert], e.alerts
  end

  test 'setting alerts with an array of Alerts sets the alerts array to contain them all' do
    a1 = EmailSignup::Alert.new
    a2 = EmailSignup::Alert.new
    e = EmailSignup.new
    e.alerts = [a2, a1]
    assert_equal [a2, a1], e.alerts
  end

  test 'setting alerts with an array with hashes and Alerts respects the order' do
    a1 = EmailSignup::Alert.new
    a2 = EmailSignup::Alert.new
    e = EmailSignup.new
    EmailSignup::Alert.stubs(:new).returns :an_alert
    e.alerts = [a2, {foo: 'bar'}, a1]
    assert_equal [a2, :an_alert, a1], e.alerts
  end

  test 'is invalid if it has no alerts' do
    e = EmailSignup.new
    refute e.valid?
    e.alerts = []
    refute e.valid?
    a = EmailSignup::Alert.new
    a.stubs(valid?: true)
    e.alerts = [a]
    assert e.valid?
  end

  test 'is invalid if any of the alerts are invalid' do
    a1 = EmailSignup::Alert.new
    a2 = EmailSignup::Alert.new
    a1.stubs(valid?: true)
    a2.stubs(valid?: false)
    e = EmailSignup.new
    e.alerts = [a1, a2]

    refute e.valid?
  end
end
