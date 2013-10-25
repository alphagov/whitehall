require 'test_helper'

class EditorialRemarkerTest < ActiveSupport::TestCase

  test '#edition_published adds an editorial remark to the edition' do
    edition = create(:published_edition)
    user    = edition.creator
    body    = 'Force published: Urgent change'
    options = { user: user, remark: body }

    Edition::EditorialRemarker.edition_published(edition, options)

    assert remark = edition.editorial_remarks.last
    assert_equal user, remark.author
    assert_equal body, remark.body
  end

  test '#edition_published does not add a remark if a user or remark is not given' do
    edition = create(:published_edition)

    Edition::EditorialRemarker.edition_published(edition, {})
    assert edition.editorial_remarks.empty?

    Edition::EditorialRemarker.edition_published(edition, { user: edition.creator })
    assert edition.editorial_remarks.empty?

    Edition::EditorialRemarker.edition_published(edition, { remark: 'Made some changes' })
    assert edition.editorial_remarks.empty?
  end
end
