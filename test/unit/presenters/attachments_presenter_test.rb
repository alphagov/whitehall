require 'test_helper'

class AttachmentsPresenterTest < ActiveSupport::TestCase
  def attachment_1
    @attachment_1 ||= stub
  end

  def attachment_2
    @attachment_2 ||= stub
  end

  def edition_has_no_attachments
    @edition.stubs(:attachments).returns([])
  end

  def edition_has_one_attachment
    @edition.stubs(:attachments).returns([attachment_1])
  end

  def edition_has_two_attachments
    @edition.stubs(:attachments).returns([attachment_1, attachment_2])
  end

  def presenter
    AttachmentsPresenter.new(@edition)
  end
end

class WithoutHtmlVersionModule < AttachmentsPresenterTest
  test 'handles an edition with no html_version method' do
    @edition = stub(:edition)
    edition_has_no_attachments
    refute presenter.any?
  end
end

class WithNoHtmlVersion < AttachmentsPresenterTest
  setup do
    @edition = stub(:edition)
    @edition.stubs(:html_version).returns(nil)
  end

  test 'accepts an edition on creation' do
    assert presenter.edition
  end

  test '#length returns the number of attachments in the edition' do
    edition_has_no_attachments
    assert_equal 0, presenter.length
    edition_has_one_attachment
    assert_equal 1, presenter.length
    edition_has_two_attachments
    assert_equal 2, presenter.length
  end

  test '#any? returns false if there are no attachments in the edition' do
    edition_has_no_attachments
    refute presenter.any?
  end

  test '#any? returns true if there is an attachment in the edition' do
    edition_has_no_attachments
    refute presenter.any?

    edition_has_one_attachment
    assert presenter.any?
  end

  test '#first returns the first attachment in the edition' do
    edition_has_one_attachment
    assert_equal attachment_1, presenter.first
  end

  test '#more_than_one? returns true if there is more than one attachment in the edition' do
    edition_has_one_attachment
    refute presenter.more_than_one?

    edition_has_two_attachments
    assert presenter.more_than_one?
  end

  test '#remaining returning all the attachments except the first one' do
    edition_has_two_attachments
    assert_equal [attachment_2], presenter.remaining
  end
end

class WhenHtmlVersionPresentTest < AttachmentsPresenterTest
  setup do
    @html_version = stub
    @edition = stub(html_version: @html_version)
  end

  test '#any? shows an attachment present when only an HTML version is in the edition' do
    edition_has_no_attachments
    assert presenter.any?
  end

  test '#first always returns the html attachment if present' do
    edition_has_no_attachments
    assert presenter.first.kind_of?(AttachmentsPresenter::HtmlAttachment)

    edition_has_one_attachment
    assert presenter.first.kind_of?(AttachmentsPresenter::HtmlAttachment)
  end

  test '#more_than_one? returns true if we have an HTML version and one attachment' do
    edition_has_one_attachment
    assert presenter.more_than_one?
  end

  test '#remaining? returns the file attachments if the HTML version is present' do
    edition_has_two_attachments
    assert_equal [attachment_1, attachment_2], presenter.remaining
  end

  test 'html attachment creating with the HTML version' do
    edition_has_no_attachments
    assert_equal @html_version, presenter.first.html_version
  end
end

class HtmlAttachmentTest < ActiveSupport::TestCase
  def html_version
    @html_version ||= stub(title: 'title', body: 'body', slug: 'slug')
  end

  def edition
    @edition ||= stub(html_version: html_version, type: 'Publication', document: stub(to_param: 'edition-slug'))
  end

  def html_attachment
    @html_attachment ||= AttachmentsPresenter::HtmlAttachment.new(edition)
  end

  test '#file_size returns the size of the body' do
    assert_equal 'body'.size, html_attachment.file_size
  end

  test '#url returns the html attachment url generated from the publication path' do
    assert_equal '/government/publications/edition-slug/slug', html_attachment.url
  end

  test '#to_param returns the slug' do
    assert_equal 'slug', html_attachment.to_param
  end

  test 'html? is true' do
    assert html_attachment.html?
  end
end
