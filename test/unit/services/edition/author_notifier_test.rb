require 'test_helper'

class Edition::AuthorNotifierTest < ActiveSupport::TestCase
  setup { ActionMailer::Base.deliveries.clear }

  test '#edition_published notifies users' do
    edition = create(:edition)
    creator = edition.creator
    second_author = create(:gds_editor)
    edition.authors << second_author

    Edition::AuthorNotifier.edition_published(edition)

    first_notification = ActionMailer::Base.deliveries.first
    assert_equal creator.email, first_notification.to[0]
    assert_match /\'#{edition.title}\' has been published/, first_notification.subject

    second_notification = ActionMailer::Base.deliveries.last
    assert_equal second_author.email, second_notification.to[0]
    assert_match /\'#{edition.title}\' has been published/, second_notification.subject
  end

  test '#edition_published will skip any users that are passed in' do
    edition = create(:edition)
    creator = edition.creator
    second_author = create(:gds_editor)
    edition.authors << second_author

    Edition::AuthorNotifier.edition_published(edition, user: second_author)

    assert_equal 1, ActionMailer::Base.deliveries.size

    first_notification = ActionMailer::Base.deliveries.first
    assert_equal creator.email, first_notification.to[0]
    assert_match /\'#{edition.title}\' has been published/, first_notification.subject
  end
end
