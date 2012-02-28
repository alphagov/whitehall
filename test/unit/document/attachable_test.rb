require 'test_helper'

class Document::AttachableTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should say a document does not have a thumbnail when it has no attachments' do
    document = create(:publication)
    refute document.has_thumbnail?
  end

  test 'should say a document does not have a thumbnail when it has no thumbnailable attachments' do
    sample_csv = create(:attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))

    document = create(:publication)
    document.attachments << sample_csv

    refute document.has_thumbnail?
  end

  test 'should say a document has a thumbnail when it has a thumbnailable attachment' do
    sample_csv = create(:attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))
    greenpaper_pdf = create(:attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'))
    two_pages_pdf = create(:attachment, file: fixture_file_upload('two-pages.pdf'))

    document = create(:publication)
    document.attachments << sample_csv
    document.attachments << greenpaper_pdf
    document.attachments << two_pages_pdf

    assert document.has_thumbnail?
  end

  test 'should return the URL of a thumbnail when the document has a thumbnailable attachment' do
    sample_csv = create(:attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))
    greenpaper_pdf = create(:attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'))
    two_pages_pdf = create(:attachment, file: fixture_file_upload('two-pages.pdf'))

    document = create(:publication)
    document.attachments << sample_csv
    document.attachments << greenpaper_pdf
    document.attachments << two_pages_pdf

    assert_equal greenpaper_pdf.url(:thumbnail), document.thumbnail_url
  end

  test "#destroy should also remove the relationship to any attachments" do
    document = create(:draft_publication, attachments: [create(:attachment)])
    relation = document.document_attachments.first
    document.destroy
    refute DocumentAttachment.find_by_id(relation.id)
  end
end
