require 'test_helper'

class EditionPublisherTest < ActiveSupport::TestCase
  test '#perform! with a valid submitted edition publishes the edition, setting the publishing timestamps and version' do
    edition = create(:submitted_edition)
    publisher = publisher_for(edition)

    assert publisher.perform!
    assert edition.published?
    assert_equal Time.zone.now.to_i, edition.first_published_at.to_i
    assert_equal Time.zone.now.to_i, edition.major_change_published_at.to_i
    assert_equal '1.0', edition.published_version
  end

  test '#perform! with an access limited edition clears the flag' do
    edition = create(:submitted_edition, :access_limited)
    publisher = publisher_for(edition)

    assert publisher.perform!
    assert edition.published?
    refute edition.access_limited?
  end

  %w(published draft imported rejected archived).each do |state|
    test "#{state} editions cannot be published" do
      edition = create(:"#{state}_edition")
      publisher = publisher_for(edition)

      refute publisher.perform!
      assert_equal state, edition.state
      assert_equal "An edition that is #{state} cannot be published", publisher.failure_reason
    end
  end

  test "#perform! with a future-scheduled edition refuses to publish" do
    edition = create(:scheduled_edition)
    publisher = publisher_for(edition)

    refute publisher.perform!
    refute edition.published?

    expected_reason = "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before"
    assert_equal expected_reason, publisher.failure_reason
  end

  test "#perform! with a scheduled edition that is ready for publishing publishes the edition" do
    edition = create(:scheduled_edition, scheduled_publication: 1.hour.ago)
    publisher = publisher_for(edition)

    assert publisher.perform!
    assert edition.published?
  end

  test '#perform! with an invalid edition refuses to publish' do
    edition = create(:submitted_edition)
    edition.title = nil
    publisher = publisher_for(edition)

    refute publisher.perform!
    refute edition.published?
    assert_equal "This edition is invalid: Title can't be blank", publisher.failure_reason
  end

  test '#perform! with a re-editioned document updates the version numbers' do
    published_edition = create(:published_edition, major_change_published_at: 1.week.ago)
    edition = published_edition.create_draft(create(:policy_writer))
    edition.minor_change = true
    edition.submit!
    publisher = publisher_for(edition)

    assert publisher.perform!
    assert edition.published?
    assert_equal '1.1', edition.reload.published_version
    assert_equal 1.week.ago, edition.major_change_published_at
  end

  test '#perform! archives all previous editions' do
    published_edition = create(:published_edition)
    edition = published_edition.create_draft(create(:policy_writer))
    edition.minor_change = true
    edition.submit!
    publisher = publisher_for(edition)
    publisher.perform!

    assert published_edition.reload.archived?, "expected previous edition to be archived but it's #{published_edition.state}"
  end

  test 'by default, subscribers include Edition::AuthorNotifier' do
    assert EditionPublisher.new(Edition.new).subscribers.include?(Edition::AuthorNotifier)
  end

  test 'subscribers can be overwritten' do
    subscribers = [stub('sub1'), stub('stub2')]
    publisher = EditionPublisher.new(Edition.new, subscribers: subscribers)

    assert_equal subscribers, publisher.subscribers
  end

  test 'successful #perform! sends the edition_published message to subscribers' do
    edition = create(:submitted_edition)
    subscriber = stub('subscriber')
    options = { one: 1, two: 2 }
    subscriber.expects(:edition_published).with(edition, options.dup)
    options[:subscribers] = [subscriber]
    publisher = EditionPublisher.new(edition, options)

    assert publisher.perform!
  end

  test 'unsuccessful #perform! does not send the edition_published message to subscribers' do
    edition = build(:draft_edition)
    subscriber = stub('subscriber')
    subscriber.expects(:edition_published).never
    options = { one: 1, two: 2, subscribers: [subscriber]}
    publisher = EditionPublisher.new(edition, options)

    refute publisher.perform!
  end

private

  def publisher_for(edition)
    EditionPublisher.new(edition, { subscribers: [] })
  end
end
