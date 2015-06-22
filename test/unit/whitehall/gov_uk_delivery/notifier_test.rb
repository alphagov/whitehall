require 'test_helper'

class Whitehall::GovUkDelivery::NotifierTest < ActiveSupport::TestCase

  def notifier_for(edition)
    Whitehall::GovUkDelivery::Notifier.new(edition)
  end

  def self.deliverable_classes
    [Announcement.concrete_descendants, Publicationesque.concrete_descendants].flatten
  end

  def self.undeliverable_classes
    Whitehall.edition_classes - deliverable_classes
  end

  def expect_govdelivery_worker_to_be_notified(edition)
    Whitehall::GovUkDelivery::Worker.expects(:notify!).with(edition, edition.public_timestamp).once
  end

  def expect_govdelivery_worker_to_not_be_notified
    Whitehall::GovUkDelivery::Worker.expects(:notify!).never
  end

  deliverable_classes.each do |klass|
    test "#{klass} is deliverable" do
      edition = build("published_#{klass.name.underscore}", relevant_to_local_government: false, public_timestamp: Time.zone.now, major_change_published_at: Time.zone.now)
      edition.stubs(:available_in_locale?).returns(true)

      expect_govdelivery_worker_to_be_notified(edition)

      notifier = notifier_for(edition)
      notifier.edition_published!
    end
  end

  undeliverable_classes.each do |klass|
    test "#{klass} is deliverable" do
      edition = build("published_#{klass.name.underscore}", relevant_to_local_government: false, public_timestamp: Time.zone.now, major_change_published_at: Time.zone.now)
      edition.stubs(:available_in_locale?).returns(true)

      expect_govdelivery_worker_to_not_be_notified

      notifier = notifier_for(edition)
      notifier.edition_published!
    end
  end

  test '#edition_published! routes editions to govuk delivery when they are not relevant to local government' do
    edition = build(:published_publication, relevant_to_local_government: false, public_timestamp: Time.zone.now)
    edition.stubs(:available_in_locale?).returns(true)

    expect_govdelivery_worker_to_be_notified(edition)

    notifier = notifier_for(edition)
    notifier.edition_published!
  end

  test '#edition_published! does nothing if the change is minor' do
    publication = create(:published_publication, topics: [create(:topic)], minor_change: true, public_timestamp: Time.zone.now)

    expect_govdelivery_worker_to_not_be_notified

    notifier = notifier_for(publication)
    notifier.edition_published!
  end

  test '#edition_published! does nothing if the edition is not available in english' do
    speech = I18n.with_locale(:es) { create(:published_speech, minor_change: false, major_change_published_at: Time.zone.now) }
    speech.stubs(:topics).returns [create(:topic)]

    expect_govdelivery_worker_to_not_be_notified

    notifier = notifier_for(speech)
    notifier.edition_published!
  end

  test '#edition_published! does nothing if the edition was published in the past' do
    publication = create(:published_publication, topics: [create(:topic)], minor_change: false, public_timestamp: 2.days.ago)

    expect_govdelivery_worker_to_not_be_notified

    notifier = notifier_for(publication)
    notifier.edition_published!
  end

  test '#edition_published! still notifies first-published speeches that were delivered less than 72 hours ago' do
    speech = create(:draft_speech, delivered_on: 2.days.ago)
    force_publish(speech)

    expect_govdelivery_worker_to_be_notified(speech)

    notifier = notifier_for(speech)
    notifier.edition_published!
  end

  test '#edition_published! does not notify a first-published speech that was delivered more than 72 hours ago' do
    speech = create(:draft_speech, delivered_on: 73.hours.ago)
    force_publish(speech)

    expect_govdelivery_worker_to_not_be_notified

    notifier = notifier_for(speech)
    notifier.edition_published!
  end

  test 'major changes to old speeches still generate a notification' do
    speech = create(:draft_speech, delivered_on: 30.days.ago)
    Timecop.travel(10.days.ago) { force_publish(speech) }

    new_edition = speech.create_draft(create(:writer))
    new_edition.change_note = 'Some major changes'
    force_publish(new_edition)

    expect_govdelivery_worker_to_be_notified(new_edition)

    notifier = notifier_for(new_edition)
    notifier.edition_published!
  end

  test 'minor changes to old speeches do not generate a notification' do
    speech = create(:draft_speech, delivered_on: 30.days.ago)
    Timecop.travel(10.days.ago) { force_publish(speech) }

    new_edition = speech.create_draft(create(:writer))
    new_edition.minor_change = true
    force_publish(new_edition)

    expect_govdelivery_worker_to_not_be_notified

    notifier = notifier_for(new_edition)
    notifier.edition_published!
  end

  test "#edition_published! does nothing if the edition is not published" do
    publication = create(:draft_publication, first_published_at: 1.hour.ago)

    expect_govdelivery_worker_to_not_be_notified

    notifier = notifier_for(publication)
    notifier.edition_published!
  end
end
