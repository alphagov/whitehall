require "test_helper"

class AttachmentDataTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
    @asset_manager_id = "asset_manager_id"
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test "should be invalid without a file" do
    attachment = build(:attachment_data, file: nil, attachable: build(:draft_publication, id: 1))
    assert_not attachment.valid?
  end

  test "is invalid with an empty file" do
    empty_file = upload_fixture("empty_file.txt", "text/plain")
    attachment = build(:attachment_data, file: empty_file, attachable: build(:draft_publication, id: 1))
    assert_not attachment.valid?
    assert_match %r{empty file}, attachment.errors[:file].first
  end

  test "returns its attachable's auth_bypass_id when it has one" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    attachable = CaseStudy.new(auth_bypass_id:)
    attachment = build(:attachment_data, attachable:)

    assert_equal [auth_bypass_id], attachment.auth_bypass_ids
  end

  test "should return filename even after reloading" do
    attachment = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    assert_not_nil attachment.filename
    assert_equal attachment.filename, AttachmentData.find(attachment.id).filename
  end

  test "should save content type and file size on create" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal "greenpaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal greenpaper_pdf.size, attachment.file_size
  end

  test "should save content type and file size on update" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    whitepaper_pdf = upload_fixture("whitepaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    attachment.update!(file: whitepaper_pdf)
    attachment.reload
    assert_equal "whitepaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal whitepaper_pdf.size, attachment.file_size
  end

  test "should set content type based on file extension when browser supplies octet-stream content type" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/octet-stream")
    attachment = create(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should set content type based on file extension when browser supplies no content type" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", nil)
    attachment = create(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should allow file in the indexable whitelist to be indexed" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", nil)
    attachment = create(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal true, attachment.indexable?
  end

  test "should set page count for PDF on create" do
    two_pages_pdf = upload_fixture("two-pages.pdf")
    attachment = create(:attachment_data, file: two_pages_pdf, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal 2, attachment.number_of_pages
  end

  test "should set page count for PDFs which have a space in their names" do
    pdf_with_spaces_in_the_name = upload_fixture("pdf with spaces in the name.pdf")
    attachment = create(:attachment_data, file: pdf_with_spaces_in_the_name, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal 1, attachment.number_of_pages
  end

  test "should set page count for PDF on update" do
    two_pages_pdf = upload_fixture("two-pages.pdf")
    three_pages_pdf = upload_fixture("three-pages.pdf")
    attachment = create(:attachment_data, file: two_pages_pdf, attachable: build(:draft_publication, id: 1))
    attachment.update!(file: three_pages_pdf)
    attachment.reload
    assert_equal 3, attachment.number_of_pages
  end

  test "should set number of pages to nil if pdf-reader cannot count the number of pages" do
    greenpage_pdf = upload_fixture("greenpaper.pdf")

    errors = %w[PDF::Reader::MalformedPDFError PDF::Reader::UnsupportedFeatureError OpenSSL::Cipher::CipherError]
    errors.each do |err|
      PDF::Reader.any_instance.stubs(:page_count).raises(err.constantize)
      attachment = create(:attachment_data, file: greenpage_pdf, attachable: build(:draft_publication, id: 1))
      attachment.reload
      assert_nil attachment.number_of_pages
    end
  end

  test "should allow CSV file types as attachments" do
    sample_from_excel_csv = upload_fixture("sample-from-excel.csv")
    attachment = create(:attachment_data, file: sample_from_excel_csv, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_equal "text/csv", attachment.content_type
  end

  test "should not set page count for non-PDF" do
    sample_from_excel_csv = upload_fixture("sample-from-excel.csv")
    attachment = create(:attachment_data, file: sample_from_excel_csv, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_nil attachment.number_of_pages
  end

  test "should be a PDF if underlying content type is application/pdf" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert attachment.pdf?
  end

  test "should not be a PDF if underlying content type is not application/pdf" do
    sample_csv = upload_fixture("sample-from-excel.csv", "text/csv")
    attachment = create(:attachment_data, file: sample_csv, attachable: build(:draft_publication, id: 1))
    attachment.reload
    assert_not attachment.pdf?
  end

  test "should successfully create PDF from the file_cache after a validation failure" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachable = create(:draft_publication, id: 1)
    attachment = build(:attachment_data, file: greenpaper_pdf, attachable:)

    second_attempt_attachment = build(:attachment_data_with_no_assets, file: nil, file_cache: attachment.file_cache, attachable:)

    Services.asset_manager.expects(:create_asset).once.with { |value|
      (value[:file].path.ends_with? "greenpaper.pdf")
    }.returns("id" => "http://asset-manager/assets/#{@asset_manager_id}", "name" => "greenpaper.pdf")

    assert second_attempt_attachment.save

    AssetManagerCreateAssetWorker.drain
  end

  test "should return nil file extension when no uploader present" do
    attachment = build(:attachment_data, attachable: build(:draft_publication, id: 1))
    attachment.stubs(file: nil)
    assert_nil attachment.file_extension
  end

  test "should return nil file extension when uploader filename not present" do
    attachment = build(:attachment_data, attachable: build(:draft_publication, id: 1))
    attachment.stubs(file: stub("uploader", file: stub("file", filename: nil)))
    assert_nil attachment.file_extension
  end

  test "should return file extension if filename present but file empty" do
    attachment = build(:attachment_data, attachable: build(:draft_publication, id: 1))
    file = stub("file", empty?: true, filename: "greenpaper.pdf")
    attachment.stubs(file: stub("uploader", file:))
    assert_equal "pdf", attachment.file_extension
  end

  test "should not be a csv if file not present" do
    attachment = build(:attachment_data, attachable: build(:draft_publication, id: 1))
    attachment.stubs(file: nil)
    assert_not attachment.csv?
  end

  test "should return file extension if file present" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = build(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    assert_equal "pdf", attachment.file_extension
  end

  test "#filename_without_extension returns the filename minus the extension" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = build(:attachment_data, file: greenpaper_pdf, attachable: build(:draft_publication, id: 1))
    assert_equal "greenpaper", attachment.filename_without_extension
  end

  test "should ensure instances know when they've been replaced by a new instance" do
    attachable = build(:draft_publication, id: 1)
    to_be_replaced = create(:attachment_data, attachable:)
    replace_with = build(:attachment_data, attachable:)
    replace_with.to_replace_id = to_be_replaced.id
    replace_with.save!
    assert_equal replace_with, to_be_replaced.reload.replaced_by
  end

  test "replace_with! won't let you replace an instance with itself" do
    self_referential = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    assert_raise(ActiveRecord::RecordInvalid) do
      self_referential.replace_with!(self_referential)
    end
  end

  test "order attachments by attachable ID" do
    attachment_data = build(:attachment_data)
    edition1 = create(:edition)
    edition2 = create(:edition)
    attachment1 = build(:file_attachment, attachable: edition2)
    attachment2 = build(:file_attachment, attachable: edition1)
    attachment_data.attachments << attachment1
    attachment_data.attachments << attachment2
    attachment_data.attachable = edition2
    attachment_data.save!
    attachment_data.reload

    assert_equal [attachment2, attachment1], attachment_data.attachments.to_a
  end

  test "#access_limited? is falsey if there is no last attachable" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_not attachment_data.access_limited?
  end

  test "#access_limited? delegates to the last attachable" do
    attachable = stub("attachable", access_limited?: "access-limited")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal "access-limited", attachment_data.access_limited?
  end

  test "#access_limited_object returns nil if there is no last attachable" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_nil attachment_data.access_limited_object
  end

  test "#access_limited_object delegates to the last attachable" do
    attachable = stub("attachable", access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal "access-limited-object", attachment_data.access_limited_object
  end

  test "#last_publicly_visible_attachment returns publicly visible attachable" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(true)
    attachment = build(:file_attachment, attachable:)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_equal attachment, attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns latest publicly visible attachable" do
    earliest_attachable = build(:edition)
    earliest_attachable.stubs(:publicly_visible?).returns(true)
    latest_attachable = build(:edition)
    latest_attachable.stubs(:publicly_visible?).returns(true)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns nil if there are no publicly visible attachables" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    attachment = build(:file_attachment, attachable:)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns nil if there are no attachables" do
    attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test "#last_attachment returns attachment for latest attachable" do
    earliest_attachable = build(:edition)
    latest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_attachment
  end

  test "#last_attachment ignores attachments without attachable" do
    earliest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal earliest_attachment, attachment_data.last_attachment
  end

  test "#last_attachment returns null attachment if no attachments" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])

    assert_instance_of Attachment::Null, attachment_data.last_attachment
  end

  test "#deleted? returns true if attachment is deleted" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable:, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test "#deleted? returns false if attachment is not deleted" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable:, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert_not attachment_data.deleted?
  end

  test "#deleted? returns true if attachment is deleted even if attachable is nil" do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test "#deleted? returns false if attachment is not deleted even if attachable is nil" do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert_not attachment_data.deleted?
  end

  test "#deleted? returns false for AttachmentData with multiple attachments, if draft off published has not been published yet" do
    attachable = create(:published_news_article, :with_file_attachment)
    new_attachable = attachable.reload.create_draft(create(:gds_editor))

    assert_equal new_attachable.attachments.count, 1

    attachment = new_attachable.attachments.first
    attachment.destroy!

    assert_not attachment.reload.attachment_data.deleted?
  end

  test "#deleted? returns true for AttachmentData with multiple attachments, if they are all on live attachables" do
    attachable = create(:published_news_article, :with_file_attachment)
    new_attachable = attachable.reload.create_draft(create(:gds_editor))
    attachment = new_attachable.attachments.first
    attachment.destroy!
    new_attachable.update!(minor_change: true)
    new_attachable.force_publish!

    assert attachment.reload.attachment_data.deleted?
  end

  test "#draft_attachment_for(user) returns the attachment with a draft edition" do
    user = build(:user)
    attachment_data = build(:attachment_data)
    published_edition = build(:edition, :published)
    draft_edition = build(:edition)
    published_attachment = build(:file_attachment, attachment_data:, attachable: published_edition)
    draft_attachment = build(:file_attachment, attachment_data:, attachable: draft_edition)
    attachment_data.stubs(:attachments).returns([published_attachment, draft_attachment])
    attachment_data.stubs(:visible_to?).returns(true)

    assert_equal attachment_data.draft_attachment_for(user), draft_attachment
  end

  test "#draft_edition_for(user) returns a draft edition when is associated with an attachment" do
    user = build(:user)
    attachment_data = build(:attachment_data)
    draft_edition = build(:edition)
    attachment = build(:file_attachment, attachment_data:, attachable: draft_edition)
    attachment_data.stubs(:attachments).returns([attachment])
    attachment_data.stubs(:visible_to?).returns(true)

    assert_equal attachment_data.draft_edition_for(user), draft_edition
  end

  test "#draft_edition_for(user) returns nil when the attachable is not an `Edition`" do
    user = build(:user)
    attachment_data = build(:attachment_data)
    response = build(:consultation_outcome)
    attachment = build(:file_attachment, attachment_data:, attachable: response)
    attachment_data.stubs(:attachments).returns([attachment])
    attachment_data.stubs(:visible_to?).returns(true)

    assert_nil attachment_data.draft_edition_for(user)
  end

  test "#draft_edition_for(user) returns nil when the attachable is not present" do
    user = build(:user)
    attachment_data = build(:attachment_data)
    attachment = build(:file_attachment, attachment_data:, attachable: nil)
    attachment_data.stubs(:attachments).returns([attachment])
    attachment_data.stubs(:visible_to?).returns(true)

    assert_nil attachment_data.draft_edition_for(user)
  end

  test "#asset_uploaded? returns true if original asset present" do
    attachment_data = build(:attachment_data)

    assert attachment_data.asset_uploaded?
  end

  test "#asset_uploaded? skips over any legacy asset variants present" do
    attachment_data = build(:attachment_data)

    original_pdf_asset = build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: attachment_data.filename)
    # Unable to set `variant: :thumbnail` here (which is what we really want to test)
    # as it's not a valid enum and there seems to be no way of stubbing it.
    # But setting to `nil` does the same thing for the purposes of this test.
    legacy_thumbnail_asset = build(:asset, asset_manager_id: "asset_manager_id_thumbnail", variant: nil, filename: "thumbnail_#{attachment_data.filename}.png")

    attachment_data.assets << original_pdf_asset
    attachment_data.assets << legacy_thumbnail_asset

    assert attachment_data.asset_uploaded?
  end

  test "#asset_uploaded? returns false if there is no asset" do
    attachment_data = build(:attachment_data_with_no_assets)

    assert_not attachment_data.asset_uploaded?
  end
end
