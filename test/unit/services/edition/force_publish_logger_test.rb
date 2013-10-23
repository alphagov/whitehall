require 'test_helper'

class ForcePublishLoggerTest < ActiveSupport::TestCase

  test '#edition_published adds an editorial remark to the edition' do
    edition = create(:published_edition)
    user    = edition.creator
    options = { user: user, reason: 'Urgent change'}

    Edition::ForcePublishLogger.edition_published(edition, options)

    assert remark = edition.editorial_remarks.last
    assert_equal user, remark.author
    assert_equal 'Force published: Urgent change', remark.body
  end
end
