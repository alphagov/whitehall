require "test_helper"

class CsvPreviewControllerTest < ActionController::TestCase
  def get_show(attachment_data)
    get :show, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }
  end

  def basename(attachment_data)
    File.basename(attachment_data.filename, '.' + attachment_data.file_extension)
  end

  def create_thumbnail_for_upload(uploader)
    FileUtils.touch("#{uploader.clean_path}.png")
  end

  view_test "GET #preview for a CSV attachment on a public edition renders the CSV preview" do
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [
      attachment = build(:csv_attachment)
    ])
    attachment_data = attachment.attachment_data

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_equal visible_edition, assigns(:edition)
    assert_equal attachment, assigns(:attachment)
    assert assigns(:csv_preview).is_a?(CsvPreview)
    assert_response :success
    assert_select '.headings h1', attachment.title
  end

  view_test "GET #preview for a CSV attachment on a public edition has links to document organiastions" do
    org_1 = create(:organisation)
    org_2 = create(:organisation)
    org_3 = create(:organisation)

    attachment = build(:csv_attachment)
    attachment_data = attachment.attachment_data

    create(:published_publication, :with_file_attachment, attachments: [attachment], organisations: [org_1, org_2, org_3])

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_select 'a[href=?]', organisation_path(org_1)
    assert_select 'a[href=?]', organisation_path(org_2)
    assert_select 'a[href=?]', organisation_path(org_3)
  end

  test "GET #preview for a CSV attachment on a non-public edition returns a not found response" do
    unpublished_edition = create(:draft_publication, :with_file_attachment, attachments: [build(:csv_attachment)])
    attachment_data = unpublished_edition.attachments.first.attachment_data

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :not_found
  end

  test "GET #preview for a non-CSV file type returns a not found response" do
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [build(:file_attachment)])
    attachment_data = visible_edition.attachments.first.attachment_data

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :not_found
  end

  test "GET #preview for a CSV attachment on an edition that has been unpublished redirects to the edition" do
    unpublished_publication = create(:draft_publication, :unpublished, :with_file_attachment, attachments: [build(:csv_attachment)])
    attachment_data = unpublished_publication.attachments.first.attachment_data

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_redirected_to publication_url(unpublished_publication.unpublishing.slug)
  end

  view_test "GET #preview handles CsvPreview::FileEncodingError errors" do
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [
      attachment = build(:csv_attachment)
    ])
    attachment_data = attachment.attachment_data

    CsvPreview.expects(:new).raises(CsvPreview::FileEncodingError)

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_equal visible_edition, assigns(:edition)
    assert_equal attachment, assigns(:attachment)
    assert_response :success
    assert_select 'p.preview-error', text: /This file could not be previewed/
  end

  view_test "GET #preview handles malformed CSV" do
    attachment = build(:csv_attachment, file: fixture_file_upload('malformed.csv'))
    attachment_data = attachment.attachment_data

    create(:published_publication, :with_file_attachment, attachments: [attachment])

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :success
    assert_select 'p.preview-error', text: /This file could not be previewed/
  end

  test "preview is not possible on CSV attachments on non-Editions" do
    attachment      = create(:csv_attachment, attachable: create(:policy_group))
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :not_found
  end

  view_test "can preview an attachment on a corporate information page" do
    corporate_information_page = create(:corporate_information_page, :published)
    attachment = create(:csv_attachment, attachable: corporate_information_page)
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)

    get :preview, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :success
    assert_select 'div.csv-preview td', text: "Office for Facial Hair Studies"
    assert_select 'div.csv-preview td', text: "£12000000"
    assert_select 'div.csv-preview td', text: "£10000000"
  end
end
