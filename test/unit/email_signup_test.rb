require 'test_helper'

class EmailSignupTest < ActiveSupport::TestCase
  test 'the list of valid_topics only includes topics with published policies' do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    policy  = create(:published_policy)
    topic_1.published_policies << policy

    assert EmailSignup.valid_topics.include?(topic_1)
    refute EmailSignup.valid_topics.include?(topic_2)
  end

  test 'the list of valid_topics includes all topical events even if they have no published policies' do
    topical_event_1 = create(:topical_event)
    topical_event_2 = create(:topical_event)
    policy  = create(:published_policy)
    topical_event_1.published_policies << policy

    assert EmailSignup.valid_topics.include?(topical_event_1)
    assert EmailSignup.valid_topics.include?(topical_event_2)
  end

  test 'the list of valid_organisations_by_type is split into ministerial and other' do
    assert_equal [:ministerial, :other], EmailSignup.valid_organisations_by_type.keys
  end

  test 'the ministerial valid_organisations_by_type only includes live orgs of type "Ministerial department"' do
    ministerial_dept_type = create(:organisation_type, name: "Ministerial department")
    other_dept_type = create(:organisation_type, name: "Non-ministerial department")
    live_ministerial_dept = create(:organisation, govuk_status: 'live', organisation_type: ministerial_dept_type)
    live_other_dept = create(:organisation, govuk_status: 'live', organisation_type: other_dept_type)
    not_live_ministerial_dept = create(:organisation, govuk_status: 'joining', organisation_type: ministerial_dept_type)

    valid_ministerial_orgs = EmailSignup.valid_organisations_by_type[:ministerial]
    assert valid_ministerial_orgs.include?(live_ministerial_dept)
    refute valid_ministerial_orgs.include?(live_other_dept)
    refute valid_ministerial_orgs.include?(not_live_ministerial_dept)
  end

  test 'the ministerial valid_organisations_by_type includes live orgs that are not of type "Ministerial department" or "Sub-organisation"' do
    ministerial_dept_type = create(:organisation_type, name: "Ministerial department")
    other_dept_type = create(:organisation_type, name: "Non-ministerial department")
    sub_org_type = create(:organisation_type, name: "Sub-organisation")
    live_ministerial_dept = create(:organisation, govuk_status: 'live', organisation_type: ministerial_dept_type)
    live_other_dept = create(:organisation, govuk_status: 'live', organisation_type: other_dept_type)
    not_live_other_dept = create(:organisation, govuk_status: 'joining', organisation_type: other_dept_type)
    live_sub_org = create(:organisation, govuk_status: 'joining', organisation_type: sub_org_type, parent_organisations: [live_ministerial_dept])

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

class EmailSignupAlertTest < ActiveSupport::TestCase
  test 'is invalid if the topic is missing' do
    a = EmailSignup::Alert.new(topic: '')
    a.valid?
    refute a.errors[:topic].empty?
  end

  test 'is invalid if the topic is not the slug of a topic from EmailSignup.valid_topics' do
    EmailSignup.stubs(:valid_topics).returns [stub(slug: 'woo')]
    a = EmailSignup::Alert.new(topic: 'meh')
    a.valid?
    refute a.errors[:topic].empty?
  end

  test 'is valid if the topic is "all" (even if that is not the slug of a topic from EmailSignup.valid_topics)' do
    EmailSignup.stubs(:valid_topics).returns [stub(slug: 'woo')]
    a = EmailSignup::Alert.new(topic: 'all')
    a.valid?
    assert a.errors[:topic].empty?
  end

  test 'is invalid if the organisation is missing' do
    a = EmailSignup::Alert.new(organisation: '')
    a.valid?
    refute a.errors[:organisation].empty?
  end

  test 'is invalid if the organisation is not the slug of a organisation from EmailSignup.valid_organisations_by_type' do
    EmailSignup.stubs(:valid_organisations_by_type).returns({ministerial: [stub(slug: 'woo')], other: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(organisation: 'meh')
    a.valid?
    refute a.errors[:organisation].empty?
  end

  test 'is valid if the organisation is "all" (even if that is not the slug of an organisation from EmailSignup.valid_organisations_by_type)' do
    EmailSignup.stubs(:valid_organisations_by_type).returns({ministerial: [stub(slug: 'woo')], other: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(organisation: 'all')
    a.valid?
    assert a.errors[:organisation].empty?
  end

  test 'is invalid if the document_type is missing' do
    a = EmailSignup::Alert.new(document_type: '')
    a.valid?
    refute a.errors[:document_type].empty?
  end

  test 'is invalid if the documemnt_type is not the type-prefixed slug of a document_type from EmailSignup.valid_document_types_by_type' do
    EmailSignup.stubs(:valid_document_types_by_type).returns({publication_type: [stub(slug: 'woo')], announcment_type: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(document_type: 'publication_type_meh')
    a.valid?
    refute a.errors[:document_type].empty?
  end

  test 'is valid if the documemnt_type is "all" (even if that is not the type-prefixed slug of a document_type from EmailSignup.valid_document_types_by_type)' do
    EmailSignup.stubs(:valid_document_types_by_type).returns({publication_type: [stub(slug: 'woo')], announcment_type: [stub(slug: 'foo')]})
    a = EmailSignup::Alert.new(document_type: 'all')
    a.valid?
    assert a.errors[:document_type].empty?
  end

  # NOTE: this is the behaviour of activerecord's boolean column
  # conversion, which we've copied rather than used directly, hence the
  # explicit testing
  test 'converts 1, "1", "t", "true", and "TRUE" to proper boolean true for info_for_local' do
    [1, "1", "t", "true", "TRUE"].each do |truthy|
      a = EmailSignup::Alert.new(info_for_local: truthy)
      assert_equal true, a.info_for_local, "expected '#{truthy}' to be true, but it wasn't"
    end
  end

  test 'treats a blank string, or nil info_for_local as nil' do
    ['', ' ', nil].each do |nilly|
      a = EmailSignup::Alert.new(info_for_local: nilly)
      assert_nil a.info_for_local, "expected '#{nilly}' to be nil, but it wasn't"
    end
  end

  test 'anything elase for info_for_local as proper boolean false' do
    ['blah', 12, 0, 'false', Date.today].each do |falsy|
      a = EmailSignup::Alert.new(info_for_local: falsy)
      assert_equal false, a.info_for_local, "expected '#{falsy}' to be false, but it wasn't"
    end
  end

  test 'extracts the generic type from the prefix of the document_type' do
    assert_equal 'publication', EmailSignup::Alert.new(document_type: 'publication_type_consultations').document_generic_type
    assert_equal 'policy', EmailSignup::Alert.new(document_type: 'policy_type_all').document_generic_type
    assert_equal 'announcement', EmailSignup::Alert.new(document_type: 'announcement_type_speehches').document_generic_type
  end

  test 'when the document_type is all, the generic type is also all' do
    assert_equal 'all', EmailSignup::Alert.new(document_type: 'all').document_generic_type
  end

  test 'extracts the specific type from the suffix of the document_type' do
    assert_equal 'consultations', EmailSignup::Alert.new(document_type: 'publication_type_consultations').document_specific_type
    assert_equal 'all', EmailSignup::Alert.new(document_type: 'policy_type_all').document_specific_type
    assert_equal 'speeches', EmailSignup::Alert.new(document_type: 'announcement_type_speeches').document_specific_type
  end

  test 'when the document_type is all, the specific type is also all' do
    assert_equal 'all', EmailSignup::Alert.new(document_type: 'all').document_specific_type
  end
end

class EmailSignupFeedUrlExtractorTest < ActiveSupport::TestCase
  test 'given an alert with a document_type prefixed with "publication_type_" the url path is /government/publications.atom' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_consultations')
    assert_match(/\/government\/publications.atom/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type of "publication_type_all" the url should have no publication_filter_option param' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_all')
    refute_match(/publication_filter_option\=/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type prefixed with "publication_type_" but not "publication_type_all" the url should have a publication_filter_option param with the prefix removed' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_consultations')
    assert_match(/publication_filter_option=consultations/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type prefixed with "announcement_type_" the url path is /government/announcements.atom' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_speeches')
    assert_match(/\/government\/announcements.atom/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type of "announcement_type_all" the url should have no announcement_filter_option param' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_all')
    refute_match(/announcement_filter_option\=/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type prefixed with "announcement_type_" but not "announcement_type_all" the url should have an announcement_filter_option param with the prefix removed' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_press-releases')
    assert_match(/announcement_filter_option=press-releases/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type of "policy_type_all" the url path is /government/policies.atom' do
    a = EmailSignup::Alert.new(document_type: 'policy_type_all')
    assert_match(/\/government\/policies.atom/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a document_type of "all" the url path is /government/policies.atom' do
    a = EmailSignup::Alert.new(document_type: 'all')
    assert_match(/\/government\/feed/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with an organisation of "all" the url should have no departments[] param' do
    a = EmailSignup::Alert.new(document_type: 'all', organisation: 'all')
    refute_match(/departments\%5B\%5D\=/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with an organisation not "all" the url should have a departments[]= param for it' do
    a = EmailSignup::Alert.new(document_type: 'all', organisation: 'decc')
    assert_match(/departments\%5B\%5D\=decc/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with a topic of "all" the url should have no topics[] param' do
    a = EmailSignup::Alert.new(document_type: 'all', topic: 'all')
    refute_match(/topics\%5B\%5D\=/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end

  test 'given an alert with an topic not "all" the url should have a topics[]= param for it' do
    a = EmailSignup::Alert.new(document_type: 'all', topic: 'environment')
    assert_match(/topics\%5B\%5D\=environment/, EmailSignup::FeedUrlExtractor.new(a).extract_feed_url)
  end
end
