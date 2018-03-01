require "test_helper"

class CsvPreviewControllerTest < ActionController::TestCase
  def get_show(attachment_data)
    get :show, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }
  end

  def basename(attachment_data)
    File.basename(attachment_data.filename, '.' + attachment_data.file_extension)
  end

  def stub_csv_file_from_public_host(attachment)
    file_path = File.join(Whitehall.clean_uploads_root, attachment.attachment_data.file.store_path)
    public_url_path = attachment.file.file.asset_manager_path
    CsvFileFromPublicHost.stubs(:new).with(public_url_path).yields(stub(path: file_path))
  end

  view_test "GET #show for a CSV attachment on a public edition renders the CSV preview" do
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [
      attachment = build(:csv_attachment)
    ])
    attachment_data = attachment.attachment_data

    stub_csv_file_from_public_host(attachment)
    get_show attachment_data

    assert_equal visible_edition, assigns(:edition)
    assert_equal attachment, assigns(:attachment)
    assert assigns(:csv_preview).is_a?(CsvPreview)
    assert_response :success
    assert_select '.headings h1', attachment.title
  end

  view_test "GET #show for a CSV attachment on a public edition has links to document organiastions" do
    org_1 = create(:organisation)
    org_2 = create(:organisation)
    org_3 = create(:organisation)

    attachment = build(:csv_attachment)
    attachment_data = attachment.attachment_data

    create(:published_publication, :with_file_attachment, attachments: [attachment], organisations: [org_1, org_2, org_3])

    stub_csv_file_from_public_host(attachment)
    get_show attachment_data

    assert_select 'a[href=?]', organisation_path(org_1)
    assert_select 'a[href=?]', organisation_path(org_2)
    assert_select 'a[href=?]', organisation_path(org_3)
  end

  test "GET #show for a CSV attachment on a non-public edition returns a not found response" do
    unpublished_edition = create(:draft_publication, :with_file_attachment, attachments: [build(:csv_attachment)])
    attachment_data = unpublished_edition.attachments.first.attachment_data

    get_show attachment_data

    assert_response :not_found
  end

  test "GET #show for a non-CSV file type returns a not found response" do
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [build(:file_attachment)])
    attachment_data = visible_edition.attachments.first.attachment_data

    get_show attachment_data

    assert_response :not_found
  end

  test "GET #show for a CSV attachment on an edition that has been unpublished redirects to the edition" do
    unpublished_publication = create(:draft_publication, :unpublished, :with_file_attachment, attachments: [build(:csv_attachment)])
    attachment_data = unpublished_publication.attachments.first.attachment_data

    get_show attachment_data

    assert_redirected_to publication_url(unpublished_publication.unpublishing.slug)
  end

  view_test "GET #show handles CsvPreview::FileEncodingError errors" do
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [
      attachment = build(:csv_attachment)
    ])
    attachment_data = attachment.attachment_data

    CsvPreview.expects(:new).raises(CsvPreview::FileEncodingError)

    stub_csv_file_from_public_host(attachment)
    get_show attachment_data

    assert_equal visible_edition, assigns(:edition)
    assert_equal attachment, assigns(:attachment)
    assert_response :success
    assert_select 'p.preview-error', text: /This file could not be previewed/
  end

  test "GET #show for attachments that aren't visible and have been replaced permanently redirects to the replacement attachment" do
    replacement = create(:csv_attachment)
    attachment_data = create(:attachment_data, replaced_by: replacement.attachment_data)

    get_show attachment_data

    assert_redirected_to replacement.url
    assert_equal 301, response.status
    assert_cache_control("max-age=#{Whitehall.uploads_cache_max_age}")
    assert_cache_control("public")
  end

  test 'GET #show for an attachment that has not been virus checked redirects to the placeholder page' do
    attachment_data = build(:attachment_data)
    attachment = build(:csv_attachment, attachment_data: attachment_data)

    create(:published_publication, :with_file_attachment_not_scanned, attachments: [attachment])

    get_show attachment_data

    assert_redirected_to placeholder_url
    assert_cache_control "max-age=#{1.minute}"
  end

  view_test "GET #show handles malformed CSV" do
    attachment = build(:csv_attachment, file: fixture_file_upload('malformed.csv'))
    attachment_data = attachment.attachment_data

    create(:published_publication, :with_file_attachment, attachments: [attachment])

    stub_csv_file_from_public_host(attachment)
    get_show attachment_data

    assert_response :success
    assert_select 'p.preview-error', text: /This file could not be previewed/
  end

  test "GET #show returns 404 for CSVs attached to non-Editions" do
    attachment      = create(:csv_attachment, attachable: create(:policy_group))
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)

    get_show attachment_data

    assert_response :not_found
  end

  view_test "GET #show succeeds for attachments on corporate information pages" do
    corporate_information_page = create(:corporate_information_page, :published)
    attachment = create(:csv_attachment, attachable: corporate_information_page)
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)

    stub_csv_file_from_public_host(attachment)
    get_show attachment_data

    assert_response :success
    assert_select 'div.csv-preview td', text: "Office for Facial Hair Studies"
    assert_select 'div.csv-preview td', text: "£12000000"
    assert_select 'div.csv-preview td', text: "£10000000"
  end
end
