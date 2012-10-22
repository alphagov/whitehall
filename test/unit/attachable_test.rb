require 'test_helper'

class AttachableTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "allows attachment" do
    assert build(:publication).allows_attachments?
  end

  test "should allow multiple attachments" do
    attachment_1 = create(:attachment)
    attachment_2 = create(:attachment)

    publication = create(:publication, :with_attachment, attachments: [attachment_1, attachment_2])

    assert_equal [attachment_1, attachment_2], publication.attachments
  end

  test "should be invalid if an edition has an attachment but no alternative format provider" do
    attachment = build(:attachment)
    publication = build(:publication, attachments: [attachment], alternative_format_provider: nil)
    refute publication.valid?
  end

  test "should be invalid if an edition has an attachment but alternative format provider has no email address set" do
    attachment = build(:attachment)
    organisation = build(:organisation, alternative_format_contact_email: nil)
    publication = build(:publication, attachments: [attachment], alternative_format_provider: organisation)
    refute publication.valid?
  end

  test "should be valid without alternative format provider if no attachments" do
    publication = build(:publication, attachments: [])
    assert publication.valid?
  end

  test "should allow deletion of attachments via nested attributes" do
    attachment_1 = create(:attachment)
    attachment_2 = create(:attachment)

    publication = create(:publication, :with_attachment, attachments: [attachment_1, attachment_2])

    edition_attachments_attributes = publication.edition_attachments.inject({}) do |h, da|
      h[da.id] = da.attributes.merge("_destroy" => (da.attachment == attachment_1 ? "1" : "0"))
      h
    end
    publication.update_attributes(edition_attachments_attributes: edition_attachments_attributes)
    publication.reload

    assert_equal [attachment_2], publication.attachments
  end

  test "should stop attachables from being updated if the attachments become invalid" do
    attachment = create(:attachment)

    publication = create(:publication, :with_attachment, attachments: [attachment])

    invalid_attribute_combination = {"price" => "123", "order_url" => ""}

    edition_attachments_attributes = publication.edition_attachments.inject({}) do |h, da|
      h[da.id] = da.attributes.merge(
        attachment_attributes: da.attachment.attributes.merge(invalid_attribute_combination)
      )
      h
    end
    publication.assign_attributes(edition_attachments_attributes: edition_attachments_attributes)
    refute publication.save
  end

  test 'should say a edition does not have a thumbnail when it has no attachments' do
    edition = create(:publication)
    refute edition.has_thumbnail?
  end

  test 'should say a edition does not have a thumbnail when it has no thumbnailable attachments' do
    sample_csv = build(:attachment, attachment_data: build(:attachment_data, file: fixture_file_upload('sample-from-excel.csv', 'text/csv')))

    edition = build(:publication)
    edition.attachments << sample_csv

    refute edition.has_thumbnail?
  end

  def build_edition_with_three_attachments
    @sample_csv = create(:attachment, attachment_data: create(:attachment_data, file: fixture_file_upload('sample-from-excel.csv', 'text/csv')))
    @greenpaper_pdf = create(:attachment, attachment_data: create(:attachment_data, file: fixture_file_upload('greenpaper.pdf', 'application/pdf')))
    @two_pages_pdf = create(:attachment, attachment_data: create(:attachment_data, file: fixture_file_upload('two-pages.pdf')))

    edition = create(:publication)
    edition.attachments << @sample_csv
    edition.attachments << @greenpaper_pdf
    edition.attachments << @two_pages_pdf

    edition
  end

  test 'should say a edition has a thumbnail when it has a thumbnailable attachment' do
    edition = build_edition_with_three_attachments

    assert edition.has_thumbnail?
  end

  test 'should return the URL of a thumbnail when the edition has a thumbnailable attachment' do
    edition = build_edition_with_three_attachments

    assert_equal @greenpaper_pdf.url(:thumbnail), edition.thumbnail_url
  end

  test 'should include attachment titles into #indexable_content' do
    attachment = create(:attachment, title: "The title of the attachment")
    edition = create(:publication, body: "Document body.")
    edition.attachments << attachment

    assert_equal "Document body. Attachment: The title of the attachment", edition.indexable_content
  end
end
