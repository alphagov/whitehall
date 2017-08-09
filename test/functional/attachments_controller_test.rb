require "test_helper"

class AttachmentsControllerTest < ActionController::TestCase
  def get_show(attachment_data)
    get :show, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }
  end

  def basename(attachment_data)
    File.basename(attachment_data.filename, '.' + attachment_data.file_extension)
  end

  test "attachment documents that aren't visible and haven't been replaced are redirected to the placeholder url" do
    get_show create(:attachment_data)

    assert_redirected_to placeholder_url
  end

  test "attachment images that aren't visible and haven't been replaced are redirected to the placeholder image" do
    get_show create(:image_attachment_data)

    assert_redirected_to @controller.view_context.path_to_image('thumbnail-placeholder.png')
  end

  test "attachments that aren't visible and have been replaced are permanently redirected to the replacement attachment" do
    replacement = create(:attachment_data)
    attachment_data = create(:attachment_data, replaced_by: replacement)
    get_show attachment_data

    assert_redirected_to replacement.url
    assert_equal 301, response.status
    assert_cache_control("max-age=#{Whitehall.uploads_cache_max_age}")
    assert_cache_control("public")
  end

  test 'document attachments that are visible are sent to the browser inline with default caching' do
    visible_edition = create(:published_publication, :with_file_attachment)
    attachment_data = visible_edition.attachments.first.attachment_data

    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    get_show attachment_data

    assert_response :success
    assert_cache_control("max-age=#{Whitehall.uploads_cache_max_age}")
    assert_match /^inline;/, response.headers['Content-Disposition']
    assert_match attachment_data.filename, response.headers['Content-Disposition']
  end

  test 'document attachments that are visible are sent with a Link: header' do
    visible_edition = create(:published_publication, :with_file_attachment)
    attachment_data = visible_edition.attachments.first.attachment_data

    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    get_show attachment_data

    assert_match response.headers['Link'], "<#{public_document_url(visible_edition)}>; rel=\"up\""
  end

  test 'attachments on policy groups are always visible' do
    attachment = create(:file_attachment, attachable: create(:policy_group))
    attachment_data = attachment.attachment_data

    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    get_show attachment_data

    assert_response :success
    assert_match attachment_data.filename, response.headers['Content-Disposition']
  end

  test 'attachments that are images are sent inline' do
    attachment_data = build(:image_attachment_data)
    visible_edition = create(
      :published_publication,
      :with_file_attachment,
      attachments: [build(:file_attachment, attachment_data: attachment_data)]
    )

    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    get_show attachment_data

    assert_response :success
    assert_match attachment_data.filename, response.headers['Content-Disposition']
    assert_match /^inline;/, response.headers['Content-Disposition']
  end

  def create_thumbnail_for_upload(uploader)
    FileUtils.touch("#{uploader.clean_path}.png")
  end

  test "requesting an attachment's thumbnail returns the thumbnail inline" do
    attachment_data = build(:attachment_data)
    visible_edition = create(
      :published_publication,
      :with_file_attachment,
      attachments: [build(:file_attachment, attachment_data: attachment_data)]
    )
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    create_thumbnail_for_upload(attachment_data.file)
    get :show, params: { id: attachment_data.to_param, file: attachment_data.filename, extension: 'png' }

    assert_response :success
    assert_match "#{attachment_data.filename}.png", response.headers['Content-Disposition']
    assert_match /^inline;/, response.headers['Content-Disposition']
  end

  test 'requesting an attachment that has not been virus checked redirects to the placeholder page' do
    attachment_data = build(:attachment_data)
    visible_edition = create(:published_publication, :with_file_attachment_not_scanned, attachments: [
      build(:file_attachment, attachment_data: attachment_data)
    ])

    get_show attachment_data

    assert_redirected_to placeholder_url
    assert_cache_control "max-age=#{1.minute}"
  end

  test "requesting an attachment on an unpublished edition redirects to the edition's unpublishing page" do
    unpublished_edition = create(:draft_publication, :unpublished, :with_file_attachment)
    attachment_data = unpublished_edition.attachments.first.attachment_data

    get_show attachment_data

    assert_redirected_to publication_url(unpublished_edition.unpublishing.slug)
  end

  test "an invalid filename returns a not found response" do
    attachment_data = create(:attachment_data)
    get :show, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: "#{attachment_data.file_extension}missing" }
    assert_response :not_found
  end

  test "editor previewed attachments are not cached" do
    draft_edition = create(:draft_edition)
    attachment = create(:file_attachment, attachable: draft_edition)
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)

    login_as(:writer)
    get :show, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :success
    assert_cache_control 'no-cache'
    assert_match attachment_data.filename, response.headers['Content-Disposition']
    assert_match /^inline;/, response.headers['Content-Disposition']
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
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [
      attachment = build(:csv_attachment)
    ], organisations: [org_1, org_2, org_3])
    attachment_data = attachment.attachment_data

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
    visible_edition = create(:published_publication, :with_file_attachment, attachments: [
      attachment = build(:csv_attachment, file: fixture_file_upload('malformed.csv'))
    ])
    attachment_data = attachment.attachment_data

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

  test 'deleted attachments on documents that have more than one edition 404' do
    edition = create(:draft_publication, :with_file_attachment)
    new_edition = create(:published_publication)
    new_edition.attachments = edition.attachments.map(&:deep_clone)
    attachment = new_edition.attachments.last
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    attachment.update_column(:deleted, true)

    get :show, params: { id: attachment_data.to_param, file: basename(attachment_data), extension: attachment_data.file_extension }

    assert_response :not_found
  end

  test 'deleted attachments on documents with one edition 404' do
    visible_edition = create(:published_publication, :with_file_attachment)
    attachment = visible_edition.attachments.first
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    attachment.update_column(:deleted, true)

    get_show attachment_data

    assert_response :not_found
  end

  test 'deleted attachments policy groups return 404' do
    attachment = create(:file_attachment, attachable: create(:policy_group))
    attachment_data = attachment.attachment_data
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    attachment.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      get_show attachment_data
    end
  end
end
