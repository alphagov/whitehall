require 'test_helper'

class Whitehall::GovUkDelivery::NotifierTest < ActiveSupport::TestCase

  def notifier_for(edition)
    Whitehall::GovUkDelivery::Notifier.new(edition)
  end

  def notification_date_for(edition)
    notifier_for(edition).notification_date
  end

  test '#edition_published! does nothing if edition does not support gov delivery notifications' do
    edition =  CaseStudy.new
    refute edition.supports_govuk_delivery_notifications?

    notifier = notifier_for(edition)
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test '#edition_published! will route the edition to govuk delivery if it is not relevant to local government' do
    edition = build(:policy, relevant_to_local_government: false, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns true
    notifier = notifier_for(edition)
    notification_end_point = Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.new(edition, Time.zone.now)
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.expects(:new).with(edition, anything).returns(notification_end_point).once
    Whitehall::GovUkDelivery::EmailCurationQueueEndPoint.expects(:new).never

    notifier.edition_published!
  end

  test '#edition_published! will route the edition to the email curation queue if it is relevant to local government' do
    edition = build(:policy, relevant_to_local_government: true, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns true
    notifier = notifier_for(edition)
    notification_end_point = Whitehall::GovUkDelivery::EmailCurationQueueEndPoint.new(edition, Time.zone.now)
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.expects(:new).never
    Whitehall::GovUkDelivery::EmailCurationQueueEndPoint.expects(:new).with(edition, anything).returns(notification_end_point).once

    notifier.edition_published!
  end

  test '#edition_published! does nothing if the change is minor' do
    policy = create(:policy, topics: [create(:topic)], minor_change: true, public_timestamp: Time.zone.now)
    notifier = notifier_for(policy)
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test '#edition_published! does nothing if the edition is not available in english' do
    speech = I18n.with_locale(:es) { create(:published_speech, minor_change: false, major_change_published_at: Time.zone.now) }
    speech.stubs(:topics).returns [create(:topic)]
    notifier = notifier_for(speech)
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test '#edition_published! does nothing if the edition notification date is not today' do
    policy = create(:policy, topics: [create(:topic)], minor_change: false, public_timestamp: Time.zone.now)
    notifier = notifier_for(policy)
    notifier.stubs(:notification_date).returns 2.days.ago
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test "#notification_date uses the major_change_published_at for the notification_date of speeches" do
    speech = create(:speech)
    speech.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    speech.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')
    assert_equal notification_date_for(speech), Time.zone.parse('2011-01-01 12:13:14')
  end

  test "#notification_date uses the public_timestamp for the notification_date of other editions" do
    policy = create(:policy)
    policy.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    policy.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')
    assert_equal notification_date_for(policy), Time.zone.parse('2010-12-31 12:13:14')
  end
end
