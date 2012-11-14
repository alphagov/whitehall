require 'test_helper'

class UploadAccessTest < ActionDispatch::IntegrationTest
  def clean_upload_root
    Rails.root.join('clean-uploads')
  end

  def path_to_upload(path)
    clean_upload_root.join(path.from(1)).to_s
  end

  def upload_and_clean_file(path)
    file_path = path_to_upload(path)
    FileUtils.mkdir_p File.dirname(file_path)
    File.open(file_path, "wb") do |f|
      f.write 'content'
    end
  end

  def get_via_nginx(path)
    get path, {}, {
      "HTTP_X_SENDFILE_TYPE" => "X-Accel-Redirect",
      "HTTP_X_ACCEL_MAPPING" => "/clean-uploads/=#{clean_upload_root}"
    }
  end

  def assert_redirected_to_placeholder_page
    assert_redirected_to "http://www.example.com/government/placeholder"
  end

  def assert_redirected_to_placeholder_image
    assert_redirected_to "http://www.example.com/government/assets/thumbnail-placeholder.png"
  end

  def assert_sent_public_upload(upload, content_type)
    assert_equal 200, response.status
    assert_equal content_type, response.content_type
    assert_equal path_to_upload(upload), response.headers['X-Accel-Redirect']
    assert_equal "max-age=1800, public", response.header['Cache-Control']
  end

  def assert_sent_private_upload(upload, content_type)
    assert_equal 200, response.status
    assert_equal content_type, response.content_type
    assert_equal path_to_upload(upload), response.headers['X-Accel-Redirect']
    assert_equal "max-age=0, private", response.header['Cache-Control']
  end

  test 'allows everone access to general uploads' do
    upload = '/government/uploads/general-upload.jpg'
    upload_and_clean_file(upload)

    get_via_nginx upload

    assert_sent_public_upload upload, Mime::JPG
  end

  test 'redirects requests for unknown uploaded images to the placeholder image' do
    get_via_nginx '/government/uploads/any-missing-image.jpg'
    assert_redirected_to_placeholder_image
  end

  test 'redirects reuests for other unknown content to the placeholder page' do
    get_via_nginx 'government/uploads/any-missing-non-image-uploads.pdf'
    assert_redirected_to_placeholder_page
  end

  test 'allows everyone access to attachments of published editions' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:published_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end

  test 'allows everyone access to thumbnails of attachments of published editions' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url + ".png"
    create(:published_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))

    get_via_nginx attachment.url + ".png"

    assert_sent_public_upload attachment.url + ".png", Mime::PNG
  end

  test 'blocks general access to attachments of unpublished editions' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:draft_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))

    get_via_nginx attachment.url

    assert_redirected_to_placeholder_page
  end

  test 'allows everyone access to attachments of published consultation responses' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:published_consultation, response: create(:response, attachments: [attachment]))

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end

  test 'blocks general access to attachments of unpublished consultation responses' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:draft_consultation, response: create(:response, attachments: [attachment]))

    get_via_nginx attachment.url

    assert_redirected_to_placeholder_page
  end

  test 'allows everyone access to attachments of published supporting pages' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:published_policy, supporting_pages: [create(:supporting_page, attachments: [attachment])])

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end

  test 'blocks general access to attachments of unpublished supporting pages' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:draft_policy, supporting_pages: [create(:supporting_page, attachments: [attachment])])

    get_via_nginx attachment.url

    assert_redirected_to_placeholder_page
  end

  test 'allows authenticated users access to attachments of unpublished supporting pages' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:draft_policy, supporting_pages: [create(:supporting_page, attachments: [attachment])])

    PublicAttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.url

    assert_sent_private_upload attachment.url, Mime::PDF
  end

  test 'allows authenticated users access to attachments of unpublished editions' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:draft_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))

    PublicAttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.url

    assert_sent_private_upload attachment.url, Mime::PDF
  end

  test 'blocks authenticated users without permission from accessing attachments of limited access documents' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    limited_access_publication = create(:draft_publication, publication_type: PublicationType::NationalStatistics, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email), access_limited: true)

    PublicAttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.url

    assert_redirected_to_placeholder_page
  end

  test 'allows authenticated users with permission to access attachments of limited access documents' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    limited_access_publication = create(:draft_publication, publication_type: PublicationType::NationalStatistics, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email), organisations: [create(:organisation)], access_limited: true)

    user_with_access = create(:user, organisation: limited_access_publication.organisations.first)

    PublicAttachmentsController.any_instance.stubs(:current_user).returns(user_with_access)

    get_via_nginx attachment.url

    assert_sent_private_upload attachment.url, Mime::PDF
  end

  test 'allows everyone access to attachments of corporate information pages' do
    attachment = create(:attachment)
    upload_and_clean_file attachment.url
    create(:corporate_information_page, attachments: [attachment])

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end
end
