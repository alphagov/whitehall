require 'test_helper'

class ServiceListeners::EditorialRemarkerTest < ActiveSupport::TestCase
  test 'adds an editorial remark to the edition' do
    edition = create(:published_edition)
    user    = edition.creator
    body    = 'Force published: Urgent change'

    ServiceListeners::EditorialRemarker.new(edition, user, body).save_remark!

    assert remark = edition.editorial_remarks.last
    assert_equal user, remark.author
    assert_equal body, remark.body
  end

  test '#edition_published does not add a remark if a user or remark is not given' do
    edition = create(:published_edition)

    ServiceListeners::EditorialRemarker.new(edition, nil, nil).save_remark!
    assert edition.editorial_remarks.empty?

    ServiceListeners::EditorialRemarker.new(edition, edition.creator, nil).save_remark!
    assert edition.editorial_remarks.empty?

    ServiceListeners::EditorialRemarker.new(edition, nil, 'Made some changes').save_remark!
    assert edition.editorial_remarks.empty?
  end
end
