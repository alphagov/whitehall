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
    publisher            = EditionForcePublisher.new(edition, user: edition.authors.first, reason: '')

    refute @return_value
    refute edition.published?
    assert_equal 'You cannot force publish an edition without a reason', publisher.failure_reason
  end

  %w(published imported rejected archived).each do |state|
    test "#{state} editions cannot be force published" do
      edition = create(:"#{state}_edition")
      publisher = EditionForcePublisher.new(edition, user: edition.authors.first, reason: 'Because')

      refute publisher.perform!
      assert_equal state, edition.state
      assert_equal "An edition that is #{state} cannot be force published", publisher.failure_reason
    end
  end
end