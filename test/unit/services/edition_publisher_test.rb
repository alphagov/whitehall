require 'test_helper'

class EditionPublisherTest < ActiveSupport::TestCase

  test '#perform! with a valid submitted edition publishes the edition, setting the publishing timestamps and version' do
    edition   = create(:submitted_edition)

    assert EditionPublisher.new(edition).perform!
    assert edition.published?
    assert_equal Time.zone.now.to_i, edition.first_published_at.to_i
    assert_equal Time.zone.now.to_i, edition.major_change_published_at.to_i
    assert_equal '1.0', edition.published_version
  end

  test '#perform! with an access limited edition clears the flag' do
    edition = create(:submitted_edition, :access_limited)

    assert EditionPublisher.new(edition).perform!
    assert edition.published?
    refute edition.access_limited?
  end

  %w(published draft imported rejected superseded).each do |state|
    test "#{state} editions cannot be published" do
      edition = create(:"#{state}_edition")
      publisher = EditionPublisher.new(edition)

      refute publisher.perform!
      assert_equal state, edition.state
      assert_equal "An edition that is #{state} cannot be published", publisher.failure_reason
    end
  end

  test "#perform! with a scheduled edition refuses to publish" do
    edition = create(:scheduled_edition)
    publisher = EditionPublisher.new(edition)

    refute publisher.perform!
    refute edition.published?

    expected_reason = "Scheduled editions cannot be published. This edition is scheduled for publication on #{edition.scheduled_publication.to_s}"
    assert_equal expected_reason, publisher.failure_reason
  end

  test '#perform! with an invalid edition refuses to publish' do
    edition = create(:submitted_edition)
    edition.title = nil
    publisher = EditionPublisher.new(edition)

    refute publisher.perform!
    refute edition.published?
    assert_equal "This edition is invalid: Title can't be blank", publisher.failure_reason
  end

  test '#perform! with a re-editioned document updates the version numbers' do
    published_edition = create(:published_edition, major_change_published_at: 1.week.ago)
    edition = published_edition.create_draft(create(:policy_writer))
    edition.minor_change = true
    edition.submit!
    publisher = EditionPublisher.new(edition)

    assert publisher.perform!
    assert edition.published?
    assert_equal '1.1', edition.reload.published_version
    assert_equal 1.week.ago, edition.major_change_published_at
  end

  test '#perform! sets a government association for the document based on first published timestamp' do
    government = create(:government)
    edition    = create(:submitted_edition, first_published_at: Time.zone.now)

    assert EditionPublisher.new(edition).perform!
    assert_equal government, edition.document.government
  end

  test '#perform! sets a government association for a speech based on delivered_on timestamp' do
    old_government = create(:government, start_date: 2.years.ago, end_date: 1.day.ago)
    current_government = create(:government, start_date: Date.today)
    edition = create(:submitted_speech, first_published_at: Time.zone.now, delivered_on: 1.day.ago)

    assert EditionPublisher.new(edition).perform!
    assert_equal old_government, edition.document.government
  end

  test '#perform! sets a government association for a consultation based on opening_at timestamp' do
    old_government = create(:government, start_date: 2.years.ago, end_date: 1.day.ago)
    current_government = create(:government, start_date: Date.today)
    edition = create(:submitted_consultation, opening_at: 1.day.ago)

    assert EditionPublisher.new(edition).perform!
    assert_equal old_government, edition.document.government
  end

  test '#perform! supersedes all previous editions' do
    published_edition = create(:published_edition)
    edition = published_edition.create_draft(create(:policy_writer))
    edition.minor_change = true
    edition.submit!
    publisher = EditionPublisher.new(edition)

    assert publisher.perform!
    assert published_edition.reload.superseded?, "expected previous edition to be superseded but it's #{published_edition.state}"
  end

  test '#perform! does not choke if previoues editions are invalid' do
    published_edition = create(:published_edition)
    edition = published_edition.create_draft(create(:policy_writer))
    edition.minor_change = true
    edition.submit!
    published_edition.update_attribute(:title, nil)
    publisher = EditionPublisher.new(edition)

    assert publisher.perform!
    assert published_edition.reload.superseded?, "expected previous edition to be superseded but it's #{published_edition.state}"
  end

  test '#perform! notifies on successful publishing' do
    edition  = create(:submitted_edition)
    options  = { one: 1, two: 2}
    notifier = mock
    notifier.expects(:publish).with('publish', edition, options)
    publisher = EditionPublisher.new(edition, options.merge(notifier: notifier))

    assert publisher.perform!
  end

  test '#perform! does not notify if publishing is unsuccessful' do
    edition  = build(:imported_edition)
    notifier = mock
    notifier.expects(:publish).never
    publisher = EditionPublisher.new(edition, {notifier: notifier})

    refute publisher.perform!
  end

  test 'a submitted edition with a scheduled publication time cannot be published' do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    publisher = EditionPublisher.new(edition)
    refute publisher.can_perform?
  end
end
