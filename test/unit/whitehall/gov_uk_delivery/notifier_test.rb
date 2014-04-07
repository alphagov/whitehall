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

  test '#edition_published! routes editions to govuk delivery when they are not relevant to local government' do
    edition = build(:published_policy, relevant_to_local_government: false, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns(true)
    notifier = notifier_for(edition)

    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).once

    notifier.edition_published!
  end

  test '#edition_published! routes editions to the email curation queue when they are relevant to local government' do
    edition = build(:published_policy, relevant_to_local_government: true, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns(true)
    notifier = notifier_for(edition)

    notifier.expects(:notify_email_curation_queue).once
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test '#notify_email_curation_queue creates an email curation queue item with the edition  and its public_timestamp' do
    timestamp = Time.zone.now
    edition = build(:published_edition, public_timestamp: timestamp)
    notifier = notifier_for(edition)

    EmailCurationQueueItem.expects(:create_from_edition).with(edition, timestamp)
    notifier.notify_email_curation_queue
  end

  test '#notify_govuk_delivery notifies the Worker with the edition and its public_timestamp' do
    timestamp = Time.zone.now
    edition = build(:published_edition, public_timestamp: timestamp)
    notifier = notifier_for(edition)

    Whitehall::GovUkDelivery::Worker.expects(:notify!).with(edition, timestamp).once
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

  test '#edition_published! does nothing if the edition was published in the past' do
    policy = create(:published_policy, topics: [create(:topic)], minor_change: false, public_timestamp: 2.days.ago)
    notifier = notifier_for(policy)
    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test '#edition_published! still notifies first-published speeches that were delivered less than 72 hours ago' do
    speech = create(:draft_speech, delivered_on: 2.days.ago)
    force_publish(speech)
    notifier = notifier_for(speech)
    notifier.expects(:notify_govuk_delivery).once

    notifier.edition_published!
  end

  test '#edition_published! does not notify a first-published speech that was delivered more than 72 hours ago' do
    speech = create(:draft_speech, delivered_on: 73.hours.ago)
    force_publish(speech)
    notifier = notifier_for(speech)
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test 'major changes to old speeches still generate a notification' do
    speech = create(:draft_speech, delivered_on: 30.days.ago)
    Timecop.travel(10.days.ago) { force_publish(speech) }

    new_edition = speech.create_draft(create(:policy_writer))
    new_edition.change_note = 'Some major changes'
    force_publish(new_edition)
    notifier = notifier_for(new_edition)
    notifier.expects(:notify_govuk_delivery).once

    notifier.edition_published!
  end

  test 'minor changes to old speeches do not generate a notification' do
    speech = create(:draft_speech, delivered_on: 30.days.ago)
    Timecop.travel(10.days.ago) { force_publish(speech) }

    new_edition = speech.create_draft(create(:policy_writer))
    new_edition.minor_change = true
    force_publish(new_edition)
    notifier = notifier_for(new_edition)
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end

  test "#edition_published! does nothing if the edition is not published" do
    policy = create(:draft_policy, first_published_at: 1.hour.ago)
    notifier = notifier_for(policy)

    notifier.expects(:notify_email_curation_queue).never
    notifier.expects(:notify_govuk_delivery).never

    notifier.edition_published!
  end
end
