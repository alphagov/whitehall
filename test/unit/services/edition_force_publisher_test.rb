require 'test_helper'

class EditionForcePublisherTest < ActiveSupport::TestCase

  test '#perform! with a valid submitted edition force publishes the edition, setting timestamps' do
    edition              = create(:draft_edition)
    publisher            = force_publisher_for(edition)

    assert publisher.perform!
    assert_equal :published, edition.current_state
    assert edition.force_published?
    assert_equal Time.zone.now.to_i, edition.major_change_published_at.to_i
    assert_equal Time.zone.now.to_i, edition.first_published_at.to_i
    assert_equal '1.0', edition.published_version
  end

  %w(published imported rejected archived).each do |state|
    test "#{state} editions cannot be force published" do
      edition = create(:"#{state}_edition")
      publisher = force_publisher_for(edition)

      refute publisher.perform!
      assert_equal state, edition.state
      assert_equal "An edition that is #{state} cannot be force published", publisher.failure_reason
    end
  end

  test 'a draft edition with a scheduled publication time cannot be force published' do
    edition = build(:draft_edition, scheduled_publication: 1.day.from_now)
    publisher = EditionForcePublisher.new(edition)
    refute publisher.can_perform?
  end

  test 'successful #perform! sends the edition_published message to subscribers' do
    edition = create(:draft_edition)
    subscriber = stub('subscriber')
    options = { user: edition.creator, remark: 'Making changes' }
    subscriber.expects(:edition_published).with(edition, options.dup)
    options[:subscribers] = [subscriber]
    publisher = EditionForcePublisher.new(edition, options)

    assert publisher.perform!
  end

private

  def force_publisher_for(edition)
    EditionForcePublisher.new(edition, { subscribers: [] })
  end
end
