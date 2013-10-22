require 'test_helper'

class EditionForcePublisherTest < ActiveSupport::TestCase

  test '#perform! with a valid submitted edition force publishes the edition, setting timestamps, version and editorial remark' do
    edition              = create(:draft_edition)
    user                 = edition.authors.first
    force_publish_reason = 'Urgent change to the document'
    publisher            = EditionForcePublisher.new(edition, user: user, reason: force_publish_reason)

    assert publisher.perform!
    assert edition.published?
    assert_equal Time.zone.now.to_i, edition.major_change_published_at.to_i
    assert_equal Time.zone.now.to_i, edition.first_published_at.to_i
    assert_equal '1.0', edition.published_version

    assert edition.force_published?

    assert remark = edition.editorial_remarks.last
    assert_equal "Force published: #{force_publish_reason}", remark.body
    assert_equal user, remark.author
  end

  test '#perform! when no reason for force publishing is given refuses to publish' do
    edition              = create(:draft_edition)
    publisher            = EditionForcePublisher.new(edition, user: edition.creator, reason: '')

    refute @return_value
    refute edition.published?
    assert_equal 'You cannot force publish an edition without a reason', publisher.failure_reason
  end

  %w(published imported rejected archived).each do |state|
    test "#{state} editions cannot be force published" do
      edition = create(:"#{state}_edition")
      publisher = EditionForcePublisher.new(edition, user: edition.creator, reason: 'Because')

      refute publisher.perform!
      assert_equal state, edition.state
      assert_equal "An edition that is #{state} cannot be force published", publisher.failure_reason
    end
  end

  test 'a draft edition with a scheduled publication time cannot be force published' do
    edition = build(:draft_edition, scheduled_publication: 1.day.from_now)
    publisher = EditionForcePublisher.new(edition, user: edition.creator, reason: 'Because')
    refute publisher.can_perform?
  end

  test 'by default, subscribers include Edition::AuthorNotifier' do
    assert EditionForcePublisher.new(Edition.new).subscribers.include?(Edition::AuthorNotifier)
  end

  test 'by default, subscribers include Whitehall::GovUkDelivery::Notifier' do
    assert EditionForcePublisher.new(Edition.new).subscribers.include?(Whitehall::GovUkDelivery::Notifier)
  end

  test 'subscribers can be overwritten' do
    subscribers = [stub('sub1'), stub('stub2')]
    publisher = EditionForcePublisher.new(Edition.new, subscribers: subscribers)

    assert_equal subscribers, publisher.subscribers
  end

  test 'successful #perform! sends the edition_published message to subscribers' do
    edition = create(:draft_edition)
    subscriber = stub('subscriber')
    options = { user: edition.creator, reason: 'Urgent update' }
    subscriber.expects(:edition_published).with(edition, options.dup)
    options[:subscribers] = [subscriber]
    publisher = EditionForcePublisher.new(edition, options)

    assert publisher.perform!
  end
end