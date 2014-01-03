require 'test_helper'

class Whitehall::GovUkDelivery::NotifierTest < ActiveSupport::TestCase

  def notifier_for(edition)
    Whitehall::GovUkDelivery::Notifier.new(edition)
  end

  def self.deliverable_classes
    [Policy, Announcement.concrete_descendants, Publicationesque.concrete_descendants].flatten
  end

  def self.undeliverable_classes
    Whitehall.edition_classes - deliverable_classes
  end

  deliverable_classes.each do |klass|
    test "#{klass} is deliverable" do
      edition = build("published_#{klass.name.underscore}", relevant_to_local_government: false, public_timestamp: Time.zone.now, major_change_published_at: Time.zone.now)
      edition.stubs(:available_in_locale?).returns(true)
      notifier = notifier_for(edition)
      notifier.expects(:notify_govuk_delivery).once

      notifier.edition_published!
    end
  end

  undeliverable_classes.each do |klass|
    test "#{klass} is deliverable" do
      edition = build("published_#{klass.name.underscore}", relevant_to_local_government: false, public_timestamp: Time.zone.now, major_change_published_at: Time.zone.now)
      edition.stubs(:available_in_locale?).returns(true)
      notifier = notifier_for(edition)
      notifier.expects(:notify_govuk_delivery).never

      notifier.edition_published!
    end
  end

  test '#edition_published! will route the edition only to govuk delivery if it is not relevant to local government' do
    edition = build(:published_policy, relevant_to_local_government: false, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns(true)
    notifier = notifier_for(edition)

    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).once

    notifier.edition_published!
  end

  test '#edition_published! will route the edition only to the email curation queue if it is relevant to local government' do
    edition = build(:published_policy, relevant_to_local_government: true, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns(true)
    notifier = notifier_for(edition)

    notifier.expects(:notify_email_curation_queue).once
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test '#notify_email_curation_queue creates an email curation queue item from the edition and notification date' do
    notification_date = stub("notification date")
    edition = build(:published_edition)
    notifier = notifier_for(edition)
    notifier.stubs(:notification_date).returns(notification_date)

    EmailCurationQueueItem.expects(:create_from_edition).with(edition, notification_date)
    notifier.notify_email_curation_queue
  end

  test '#notify_govuk_delivery notifies the Worker of the edition' do
    notification_date = stub("notification date")
    edition = build(:published_edition)
    notifier = notifier_for(edition)
    notifier.stubs(:notification_date).returns(notification_date)

    Whitehall::GovUkDelivery::Worker.expects(:notify!).with(edition, notification_date).once
    notifier.notify_govuk_delivery
  end

  test '#edition_published! does nothing if the change is minor' do
    policy = create(:published_policy, topics: [create(:topic)], minor_change: true, public_timestamp: Time.zone.now)
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
    policy = create(:published_policy, topics: [create(:topic)], minor_change: false, public_timestamp: Time.zone.now)
    notifier = notifier_for(policy)
    notifier.stubs(:notification_date).returns 2.days.ago
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test "#notification_date uses the major_change_published_at for the notification_date of speeches" do
    speech = create(:published_speech)
    speech.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    speech.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')

    Whitehall::GovUkDelivery::Worker.expects(:notify!).with(speech, Time.zone.parse('2011-01-01 12:13:14')).once
    notifier_for(speech).notify_govuk_delivery
  end

  test "#notification_date uses the public_timestamp for the notification_date of other editions" do
    policy = create(:published_policy)
    policy.major_change_published_at = Time.zone.parse('2011-01-01 12:13:14')
    policy.public_timestamp = Time.zone.parse('2010-12-31 12:13:14')

    Whitehall::GovUkDelivery::Worker.expects(:notify!).with(policy, Time.zone.parse('2010-12-31 12:13:14')).once
    notifier_for(policy).notify_govuk_delivery
  end
end
