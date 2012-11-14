require 'test_helper'

class UploadAccessTest < ActionDispatch::IntegrationTest
  setup do
    CarrierWave.configure do |config|
      require 'whitehall/quarantined_file_storage'
      config.reset_config
      config.storage Whitehall::QuarantinedFileStorage
      config.enable_processing = false if Rails.env.test?

      config.incoming_root = Rails.root.join 'incoming-uploads'
      config.clean_root = Rails.root.join 'public/government/uploads'
    end
  end

  teardown do
    CarrierWave::Uploader::Base.reset_config
    load Rails.root + 'config/initializers/carrierwave.rb'
  end

  def clean_upload_root
    Rails.root.join('clean-uploads')
  end

  def path_to_clean_upload(path)
    clean_upload_root.join(path.from("/government/uploads/".size))
  end

  def nginx_path_to_clean_upload(path)
    path_to_clean_upload(path).to_s.from(Rails.root.to_s.size)
  end

  def create_uploaded_file(path)
    FileUtils.mkdir_p File.dirname(path)
    File.open(path, "wb") do |f|
      f.write 'content'
    end
  end

  def clean_attached_file(attachment)
    incoming_path = attachment.file.path
    clean_path = incoming_path.gsub('incoming-uploads', 'clean-uploads')
    FileUtils.mkdir_p File.dirname(clean_path)
    FileUtils.mv(incoming_path, clean_path)
  end

  def get_via_nginx(path)
    get path, {}, {
      "HTTP_X_SENDFILE_TYPE" => "X-Accel-Redirect",
      "HTTP_X_ACCEL_MAPPING" => "#{clean_upload_root}/=/clean-uploads/"
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
    assert_equal nginx_path_to_clean_upload(upload), response.headers['X-Accel-Redirect']
    assert_equal "max-age=1800, public", response.header['Cache-Control']
  end

  def assert_sent_private_upload(upload, content_type)
    assert_equal 200, response.status
    assert_equal content_type, response.content_type
    assert_equal "max-age=0, private", response.header['Cache-Control']
  end

  test 'allows everyone access to general uploads' do
    upload = '/government/uploads/general-upload.jpg'
    create_uploaded_file(path_to_clean_upload(upload))

    get_via_nginx upload

    assert_sent_public_upload upload, Mime::JPG
  end

  test 'redirects requests for unknown uploaded images to the placeholder image' do
    get_via_nginx '/government/uploads/any-missing-image.jpg'
    assert_redirected_to_placeholder_image
  end

  test 'redirects requests for other unknown content to the placeholder page' do
    get_via_nginx 'government/uploads/any-missing-non-image-uploads.pdf'
    assert_redirected_to_placeholder_page
  end

  test 'allows everyone access to attachments of published editions' do
    attachment = create(:attachment)
    create(:published_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))
    clean_attached_file(attachment)

    get_via_nginx attachment.reload.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end

  test 'allows everyone access to thumbnails of attachments of published editions' do
    attachment = create(:attachment)
    create(:published_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))
    thumbnail_path = path_to_clean_upload(attachment.reload.url + ".png")
    create_uploaded_file(thumbnail_path)

    get_via_nginx attachment.url + ".png"

    assert_sent_public_upload attachment.url + ".png", Mime::PNG
  end

  test 'blocks general access to attachments of unpublished editions' do
    attachment = create(:attachment)
    create(:draft_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))
    clean_attached_file(attachment)

    get_via_nginx attachment.reload.url

    assert_redirected_to_placeholder_page
  end

  test 'allows everyone access to attachments of published consultation responses' do
    attachment = create(:attachment)
    create(:published_consultation, response: create(:response, attachments: [attachment]))
    clean_attached_file(attachment)

    get_via_nginx attachment.reload.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end

  test 'blocks general access to attachments of unpublished consultation responses' do
    attachment = create(:attachment)
    create(:draft_consultation, response: create(:response, attachments: [attachment]))
    clean_attached_file(attachment)

    get_via_nginx attachment.reload.url

    assert_redirected_to_placeholder_page
  end

  test 'allows everyone access to attachments of published supporting pages' do
    attachment = create(:attachment)
    create(:published_policy, supporting_pages: [create(:supporting_page, attachments: [attachment])])
    clean_attached_file(attachment)

    get_via_nginx attachment.reload.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end

  test 'blocks general access to attachments of unpublished supporting pages' do
    attachment = create(:attachment)
    create(:draft_policy, supporting_pages: [create(:supporting_page, attachments: [attachment])])
    clean_attached_file(attachment)

    get_via_nginx attachment.reload.url

    assert_redirected_to_placeholder_page
  end

  test 'allows authenticated users access to attachments of unpublished supporting pages' do
    attachment = create(:attachment)
    create(:draft_policy, supporting_pages: [create(:supporting_page, attachments: [attachment])])
    clean_attached_file(attachment)

    AttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.reload.url

    assert_sent_private_upload attachment.url, Mime::PDF
  end

  test 'allows authenticated users access to attachments of unpublished editions' do
    attachment = create(:attachment)
    create(:draft_publication, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email))
    clean_attached_file(attachment)

    AttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.reload.url

    assert_sent_private_upload attachment.url, Mime::PDF
  end

  test 'blocks authenticated users without permission from accessing attachments of limited access documents' do
    attachment = create(:attachment)
    limited_access_publication = create(:draft_publication, publication_type: PublicationType::NationalStatistics, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email), access_limited: true)
    clean_attached_file(attachment)

    AttachmentsController.any_instance.stubs(:current_user).returns(create(:user))

    get_via_nginx attachment.reload.url

    assert_redirected_to_placeholder_page
  end

  test 'allows authenticated users with permission to access attachments of limited access documents' do
    attachment = create(:attachment)
    limited_access_publication = create(:draft_publication, publication_type: PublicationType::NationalStatistics, attachments: [attachment], alternative_format_provider: create(:organisation_with_alternative_format_contact_email), organisations: [create(:organisation)], access_limited: true)
    clean_attached_file(attachment)
    user_with_access = create(:user, organisation: limited_access_publication.organisations.first)

    AttachmentsController.any_instance.stubs(:current_user).returns(user_with_access)

    get_via_nginx attachment.reload.url

    assert_sent_private_upload attachment.url, Mime::PDF
  end

  test 'allows everyone access to attachments of corporate information pages' do
    attachment = create(:attachment)
    create(:corporate_information_page, attachments: [attachment])
    clean_attached_file(attachment)

    get_via_nginx attachment.url

    assert_sent_public_upload attachment.url, Mime::PDF
  end
end
