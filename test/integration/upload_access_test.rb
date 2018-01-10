require 'test_helper'

class UploadAccessTest < ActionDispatch::IntegrationTest
  include CacheControlTestHelpers

  def path_to_clean_upload(path)
    File.join(Whitehall.clean_uploads_root, path.from("/government/uploads".size))
  end

  def nginx_path_to_clean_upload(path)
    path_to_clean_upload(path).to_s.sub(/^#{Whitehall.uploads_root}/, '')
  end

  def create_uploaded_file(path)
    FileUtils.mkdir_p File.dirname(path)
    File.open(path, "wb") do |f|
      f.write 'content'
    end
  end

  def get_via_nginx(path)
    get path, params: {}, headers: {
      "HTTP_X_SENDFILE_TYPE" => "X-Accel-Redirect",
      "HTTP_X_ACCEL_MAPPING" => "#{Whitehall.clean_uploads_root}/=/clean-uploads/"
    }
  end

  def assert_redirected_to_placeholder_image
    assert_redirected_to "/government/assets/thumbnail-placeholder.png"
  end

  def assert_sent_public_upload(upload, content_type)
    assert_equal 200, response.status
    assert_equal content_type, response.content_type
    assert_equal nginx_path_to_clean_upload(upload), response.headers['X-Accel-Redirect']
    assert_equal "max-age=#{Whitehall.uploads_cache_max_age}, public", response.header['Cache-Control']
  end

  def assert_sent_private_upload(_upload, content_type)
    assert_equal 200, response.status
    assert_equal content_type, response.content_type
    assert_cache_control "no-cache"
  end

  setup do
    asset_host = URI.parse(Plek.new.public_asset_host).host
    host! asset_host
  end

  test 'allows everyone access to general uploads' do
    upload = '/government/uploads/general-upload.jpg'
    create_uploaded_file(path_to_clean_upload(upload))

    get_via_nginx upload

    assert_sent_public_upload upload, Mime[:jpg]
  end

  test 'recognises files with uppercase names (as well as lowercase)' do
    upload = '/government/uploads/GENERAL-UPLOAD.JPG'
    create_uploaded_file(path_to_clean_upload(upload))

    get_via_nginx upload

    assert_sent_public_upload upload, Mime[:jpg]
  end

  test 'redirects requests for unknown uploaded images to the placeholder image' do
    get_via_nginx '/government/uploads/any-missing-image.jpg'
    assert_redirected_to_placeholder_image
  end

  test 'allows everyone access to attachments of published editions' do
    alternative_format_provider = create(:organisation_with_alternative_format_contact_email)
    attachment = build(:file_attachment)

    create(:published_publication,
           alternative_format_provider: alternative_format_provider,
           attachments: [attachment])
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime[:pdf]
  end

  test 'allows everyone access to thumbnails of attachments of published editions' do
    alternative_format_provider = create(:organisation_with_alternative_format_contact_email)
    attachment = build(:file_attachment)

    create(:published_publication,
           alternative_format_provider: alternative_format_provider,
           attachments: [attachment])
    thumbnail_path = path_to_clean_upload(attachment.url + ".png")
    create_uploaded_file(thumbnail_path)

    get_via_nginx attachment.url + ".png"

    assert_sent_public_upload attachment.url + ".png", Mime[:png]
  end

  test 'blocks general access to attachments of unpublished editions' do
    alternative_format_provider = create(:organisation_with_alternative_format_contact_email)
    attachment = build(:file_attachment)

    create(:draft_publication,
           alternative_format_provider: alternative_format_provider,
           attachments: [attachment])
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    get_via_nginx attachment.url

    assert_response :not_found
  end

  test 'allows everyone access to attachments of published consultation responses' do
    attachment = build(:file_attachment)
    consultation_outcome = create(:consultation_outcome, attachments: [attachment])

    create(:published_consultation, outcome: consultation_outcome)

    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime[:pdf]
  end

  test 'blocks general access to attachments of unpublished consultation responses' do
    attachment = build(:file_attachment)
    consultation_outcome = create(:consultation_outcome, attachments: [attachment])

    create(:draft_consultation, outcome: consultation_outcome)
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    get_via_nginx attachment.url

    assert_response :not_found
  end

  test 'allows authenticated users access to attachments of unpublished editions' do
    alternative_format_provider = create(:organisation_with_alternative_format_contact_email)
    attachment = build(:file_attachment)

    create(:draft_publication,
           alternative_format_provider: alternative_format_provider,
           attachments: [attachment])
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    AttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.url

    assert_sent_private_upload attachment.url, Mime[:pdf]
  end

  test 'blocks authenticated users without permission from accessing attachments of limited access documents' do
    alternative_format_provider = create(:organisation_with_alternative_format_contact_email)
    attachment = build(:file_attachment)

    create(:draft_publication,
           publication_type: PublicationType::NationalStatistics,
           alternative_format_provider: alternative_format_provider,
           access_limited: true,
           attachments: [attachment])
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    AttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.url

    assert_response :not_found
  end

  test 'allows authenticated users with permission to access attachments of limited access documents' do
    alternative_format_provider = create(:organisation_with_alternative_format_contact_email)
    attachment = build(:file_attachment)
    organisation = create(:organisation)

    limited_access_publication = create(
      :draft_publication,
      publication_type: PublicationType::NationalStatistics,
      alternative_format_provider: alternative_format_provider,
      organisations: [organisation],
      access_limited: true,
      attachments: [attachment]
    )
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)
    user_with_access = create(:user, organisation: limited_access_publication.organisations.first)

    AttachmentsController.any_instance.stubs(:current_user).returns(user_with_access)

    get_via_nginx attachment.url

    assert_sent_private_upload attachment.url, Mime[:pdf]
  end

  test 'allows everyone access to attachments of corporate information pages' do
    create(:corporate_information_page, :published, attachments: [
      attachment = build(:file_attachment)
    ])
    VirusScanHelpers.simulate_virus_scan(attachment.attachment_data.file)

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime[:pdf]
  end

  test 'redirects requests for old consultation response form uploads to their new location as consultation response form data uploads' do
    get_via_nginx '/government/uploads/system/uploads/consultation_response_form/something/anything/a-form.pdf'
    assert_redirected_to '/government/uploads/system/uploads/consultation_response_form_data/something/anything/a-form.pdf'
  end
end
