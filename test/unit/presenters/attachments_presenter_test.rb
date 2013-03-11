require 'fast_test_helper'

class AttachmentsPresenterTest < ActiveSupport::TestCase
  setup do
    @edition = stub
    @presenter = AttachmentsPresenter.new(@edition)
    @attachment_1 = stub
    @attachment_2 = stub
  end

  def edition_has_no_attachments
    @edition.stubs(:attachments).returns([])
  end

  def edition_has_one_attachment
    @edition.stubs(:attachments).returns([@attachment_1])
  end

  def edition_has_two_attachments
    @edition.stubs(:attachments).returns([@attachment_1, @attachment_2])
  end

  test 'accepts an edition on creation' do
    assert @presenter.edition
  end

  test '#any? returns true if there is an attachment in the edition' do
    edition_has_no_attachments
    refute @presenter.any?

    edition_has_one_attachment
    assert @presenter.any?
  end

  test '#first returns the first attachment in the edition' do
    edition_has_one_attachment
    assert_equal @attachment_1, @presenter.first
  end

  test '#more_than_one? returns true if there is more than one attachment in the edition' do
    edition_has_one_attachment
    refute @presenter.more_than_one?

    edition_has_two_attachments
    assert @presenter.more_than_one?
  end

  test '#remaining returning all the attachments except the first one' do
    edition_has_two_attachments
    assert_equal [@attachment_2], @presenter.remaining
  end
end
