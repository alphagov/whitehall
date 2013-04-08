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

end
