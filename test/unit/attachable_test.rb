require 'test_helper'

class AttachableTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "allows attachment" do
    assert build(:publication).allows_attachments?
  end

  test "allows different attachment types" do
    attachable = Publication.new
    assert attachable.allows_attachment_type?('file')
    assert attachable.allows_attachment_type?('external')
    assert attachable.allows_attachment_type?('html')
    refute attachable.allows_attachment_type?('unknown')
  end

  test "new attachments are put to the end of the list" do
    publication = create(:publication, :with_file_attachment, attachments: [
      attachment_1 = build(:file_attachment, ordering: 0),
      attachment_2 = build(:file_attachment, ordering: 1, file: file_fixture('whitepaper.pdf'))
    ])

    attachment_3 = FileAttachment.new(title: 'Title', attachment_data: build(:attachment_data, file: file_fixture('sample.rtf')))
    publication.attachments << attachment_3

    assert_equal [attachment_1, attachment_2, attachment_3], publication.attachments.reload
  end

  test "creating a new attachable thing with multiple attachments sets the correct ordering" do
    publication = build(:publication, :with_file_attachment, attachments: [
      attachment_1 = build(:file_attachment),
      attachment_2 = build(:file_attachment, file: file_fixture('whitepaper.pdf'))
    ])

    publication.save!
    assert_equal [attachment_1, attachment_2], publication.attachments
    assert_equal 0, attachment_1.ordering
    assert_equal 1, attachment_2.ordering
  end

  test "should be invalid if an edition has an attachment but no alternative format provider" do
    attachment = build(:file_attachment)
    publication = build(:publication, attachments: [attachment], alternative_format_provider: nil)
    refute publication.valid?
  end

  test "should be invalid if an edition has an attachment but alternative format provider has no email address set" do
    attachment = build(:file_attachment)
    organisation = build(:organisation, alternative_format_contact_email: nil)
    publication = build(:publication, attachments: [attachment], alternative_format_provider: organisation)
    refute publication.valid?
  end

  test "should be invalid if an edition has an attachment but not yet passed virus scanning" do
    attachment = build(:file_attachment)
    attachment.stubs(:virus_status).returns :infected
    publication = create(:publication, :with_alternative_format_provider, attachments: [attachment])
    publication.skip_virus_status_check = false
    assert publication.valid?
    user = create(:departmental_editor)
    publication.change_note = "change-note"
    assert_raise(ActiveRecord::RecordInvalid, "Validation failed: Attachments must have passed virus scanning") { force_publish(publication) }
    refute publication.published?
  end

  test "should be valid without alternative format provider if no attachments" do
    publication = build(:publication, attachments: [])
    assert publication.valid?
  end

  test 'should say a edition does not have a thumbnail when it has no attachments' do
    edition = create(:publication)
    refute edition.has_thumbnail?
  end

  test 'should say a edition does not have a thumbnail when it has no thumbnailable attachments' do
    sample_csv = build(:file_attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))

    edition = build(:publication)
    edition.attachments << sample_csv

    refute edition.has_thumbnail?
  end

  def build_edition_with_three_attachments
    edition = create(:publication)

    edition.attachments << @sample_csv = create(:file_attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'), attachable: edition)
    edition.attachments << @greenpaper_pdf = create(:file_attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'), attachable: edition)
    edition.attachments << @two_pages_pdf = create(:file_attachment, file: fixture_file_upload('two-pages.pdf'), attachable: edition)

    edition
  end

  test 'should say an edition has a thumbnail when it has a thumbnailable attachment' do
    edition = build_edition_with_three_attachments

    assert edition.has_thumbnail?
  end

  test 'should return the URL of a thumbnail when the edition has a thumbnailable attachment' do
    edition = build_edition_with_three_attachments

    assert_equal @greenpaper_pdf.url(:thumbnail), edition.thumbnail_url
  end

  test 'should include attachment details into the #search_index' do
    edition = create(:publication, :with_file_attachment, attachments: [
      attachment = build(:file_attachment, title: "The title of the attachment",
                                           hoc_paper_number: "1234", parliamentary_session: '2013-14',
                                           command_paper_number: "Cm. 1234", unique_reference: "w123",
                                           isbn: "0140620222"
      )
    ])

    index = edition.attachments.to_a.index { |attachment| attachment.kind_of?(FileAttachment) }

    assert_equal "The title of the attachment", edition.search_index['attachments'][index][:title]
    assert_equal attachment.isbn, edition.search_index['attachments'][index][:isbn]
    assert_equal attachment.unique_reference, edition.search_index['attachments'][index][:unique_reference]
    assert_equal attachment.command_paper_number, edition.search_index['attachments'][index][:command_paper_number]
    assert_equal attachment.hoc_paper_number, edition.search_index['attachments'][index][:hoc_paper_number]
  end

  test 'should include html_attachment content into the #search_index' do
    edition = create(:publication, :with_html_attachment, attachments: [
      build(:html_attachment, title: "The title of the HTML attachment",
                                           unique_reference: "w123",
                                           body: "##Test HTML attachment"
      )
    ])

    assert_equal "The title of the HTML attachment", edition.search_index['attachments'][0][:title]
    assert_equal "w123", edition.search_index['attachments'][0][:unique_reference]
    assert_equal "Test HTML attachment", edition.search_index['attachments'][0][:content]
  end

  test '#reorder_attachments should update the ordering of its attachments' do
    attachable = create(:consultation)
    a, b, c = 3.times.map { create(:file_attachment, attachable: attachable) }

    attachable.reload.reorder_attachments([b.id, a.id, c.id])

    assert_equal [b, a, c], attachable.reload.attachments
  end

  test '#reorder_attachments should handle existing negative orderings' do
    attachable = create(:consultation)
    a = create(:file_attachment, attachable: attachable, ordering: -1)
    b = create(:file_attachment, attachable: attachable, ordering: 0, file: file_fixture('whitepaper.pdf'))
    c = create(:file_attachment, attachable: attachable, ordering: 1, file: file_fixture('simple.pdf'))

    attachable.reload.reorder_attachments([b.id, a.id, c.id])

    assert_equal [b, a, c], attachable.reload.attachments
  end

  test '#reorder_attachments handles deleted attachments that had high ordering values' do
    attachable = create(:consultation)
    a = create(:file_attachment, attachable: attachable, ordering: 0)
    b = create(:file_attachment, attachable: attachable, ordering: 1)
    create(:file_attachment, attachable: attachable, ordering: 2, deleted: true)

    attachable.reload.reorder_attachments([b.id, a.id])

    assert_equal [b, a], attachable.reload.attachments
  end

  test '#reorder_attachments handles deleted attachments that had low ordering values' do
    attachable = create(:consultation)
    create(:file_attachment, attachable: attachable, ordering: 0, deleted: true)
    create(:file_attachment, attachable: attachable, ordering: 1, deleted: true)
    create(:file_attachment, attachable: attachable, ordering: 2, deleted: true)
    a = create(:file_attachment, attachable: attachable, ordering: 3)
    b = create(:file_attachment, attachable: attachable, ordering: 4)

    attachable.reload.reorder_attachments([b.id, a.id])

    assert_equal [b, a], attachable.reload.attachments
  end

  test 'has html_attachments association to fetch only HtmlAttachments' do
    publication = create(:publication, :with_file_attachment, attachments: [
      attachment_1 = build(:file_attachment, ordering: 0),
      attachment_2 = build(:html_attachment, title: "Test HTML attachment", ordering: 1),
    ])

    attachment_3 = build(:html_attachment, title: 'Title', body: "Testing")
    publication.attachments << attachment_3

    assert_equal [attachment_2, attachment_3], publication.html_attachments.reload
  end

  test 'attachment association excludes soft-deleted Attachments' do
    publication = create(:publication, :with_file_attachment, attachments: [
      attachment_1 = build(:file_attachment),
      build(:html_attachment, title: "HTML attachment", deleted: true),
    ])

    assert_equal [attachment_1], publication.attachments.reload
  end

  test 'html_attachment association excludes soft-deleted HtmlAttachments' do
    publication = create(:publication, attachments: [
      attachment_1 = build(:html_attachment, title: "Test HTML attachment"),
      build(:html_attachment, title: "Another HTML attachment", deleted: true),
    ])

    assert_equal [attachment_1], publication.html_attachments.reload
  end

  test '#has_command_paper? is true if an attachment is a command paper' do
    pub = build(:publication)
    pub.stubs(:attachments).returns([
      OpenStruct.new(is_command_paper?: false)
    ])
    refute pub.has_command_paper?

    pub.stubs(:attachments).returns([
      OpenStruct.new(is_command_paper?: false),
      OpenStruct.new(is_command_paper?: true)
    ])
    assert pub.has_command_paper?
  end

  test '#has_act_paper? is true if an attachment is an act paper' do
    pub = build(:publication)
    pub.stubs(:attachments).returns([
      OpenStruct.new(is_act_paper?: false)
    ])
    refute pub.has_act_paper?

    pub.stubs(:attachments).returns([
      OpenStruct.new(is_act_paper?: false),
      OpenStruct.new(is_act_paper?: true)
    ])
    assert pub.has_act_paper?
  end

  test 're-editioned editions deep-clones attachments' do
    file_attachment = build(:file_attachment, attachable: nil, ordering: 0)
    html_attachment = build(:html_attachment, attachable: nil, ordering: 1)
    publication = create(:published_publication, :with_alternative_format_provider,
                    attachments: [file_attachment, html_attachment])

    draft = publication.create_draft(create(:writer))

    assert_equal 2, draft.attachments.size

    attachment_1 = draft.attachments[0]
    assert attachment_1.persisted?
    assert file_attachment.id != attachment_1.id
    assert_equal file_attachment.attachment_data, attachment_1.attachment_data
    assert_equal file_attachment.title, attachment_1.title

    attachment_2 = draft.attachments[1]
    assert attachment_2.persisted?
    assert html_attachment.id != attachment_2.id
    assert_equal html_attachment.govspeak_content.body, attachment_2.govspeak_content.body
    assert_equal html_attachment.title, attachment_2.title
  end

  test '#delete_all_attachments soft-deletes any attachments that the edition has' do
    publication = create(:draft_publication)

    publication.attachments << attachment_1 = build(:file_attachment)
    publication.attachments << attachment_2 = build(:html_attachment)

    publication.delete_all_attachments

    assert Attachment.find(attachment_1.id).deleted?
    assert Attachment.find(attachment_2.id).deleted?
  end

  test "#deleted_html_attachments returns associated HTML attachments that have been deleted" do
    publication = create(:draft_publication, attachments: [
      attachment_1 = build(:html_attachment, title: "First"),
      attachment_2 = build(:html_attachment, title: "Second"),
    ])

    attachment_1.destroy
    attachment_2.destroy

    assert_equal [attachment_1, attachment_2], publication.deleted_html_attachments
  end

  test "#deleted_html_attachments doesn't return undeleted attachments" do
    publication = create(:draft_publication, attachments: [
      build(:html_attachment, title: "First"),
    ])

    assert_empty publication.deleted_html_attachments
  end
end
