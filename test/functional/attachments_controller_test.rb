require "test_helper"

class AttachmentsControllerTest < ActionController::TestCase

  def get_show(attachment_data)
    get :show, id: attachment_data.to_param, file: File.basename(attachment_data.filename, ".#{attachment_data.file_extension}"), extension: attachment_data.file_extension
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
  end

  test 'document attachments that are visible are sent to the browser inline' do
    visible_edition = create(:published_publication, :with_file_attachment)
    attachment_data = visible_edition.attachments.first.attachment_data

    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    get_show attachment_data

    assert_response :success
    assert_match /^inline;/, response.headers['Content-Disposition']
    assert_match attachment_data.filename, response.headers['Content-Disposition']
  end

  test 'attachments on policy groups are always visible' do
    attachment = create(:file_attachment, attachable: create(:policy_advisory_group))
    attachment_data = attachment.attachment_data

    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    get_show attachment_data

    assert_response :success
    assert_match attachment_data.filename, response.headers['Content-Disposition']
  end

  test 'attachments that are images are sent inline' do
    attachment_data = create(:image_attachment_data)
    visible_edition = create(
      :published_publication,
      :with_file_attachment,
      attachments: [create(:file_attachment, attachment_data: attachment_data)]
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
    attachment_data = create(:attachment_data)
    visible_edition = create(
      :published_publication,
      :with_file_attachment,
      attachments: [create(:file_attachment, attachment_data: attachment_data)]
    )
    VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    create_thumbnail_for_upload(attachment_data.file)
    get :show, id: attachment_data.to_param, file: attachment_data.filename, extension: 'png'

    assert_response :success
    assert_match "#{attachment_data.filename}.png", response.headers['Content-Disposition']
    assert_match /^inline;/, response.headers['Content-Disposition']
  end

  test 'requesting an attachment that has not been virus checked redirects to the placeholder page' do
    attachment_data = create(:attachment_data)
    visible_edition = create(:published_publication, :with_file_attachment_not_scanned, attachments: [create(:attachment, attachment_data: attachment_data)])

    get_show attachment_data

    assert_redirected_to placeholder_url
  end

  test "requesting an attachment on an unpublished edition redirects to the edition's unpublishing page" do
    unpublished_edition = create(:draft_publication, :unpublished, :with_file_attachment)
    attachment_data = unpublished_edition.attachments.first.attachment_data

    get_show attachment_data

    assert_redirected_to publication_url(unpublished_edition.unpublishing.slug)
  end

  test "an invalid filename returns a 404" do
    attachment_data = create(:attachment_data)
    get :show, id: attachment_data.to_param, file: File.basename(attachment_data.filename, ".#{attachment_data.file_extension}"), extension: "#{attachment_data.file_extension}missing"
    assert_response :not_found
  end

  private

  def create_thumbnail_for_upload(uploader)
    FileUtils.touch("#{uploader.clean_path}.png")
  end
end
