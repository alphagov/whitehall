require "test_helper"

class Admin::EditionImagesControllerTest < ActionDispatch::IntegrationTest
  test "redirects users without the 'Preview images update' permission" do
    edition = create(:draft_publication)
    login_as create(:gds_editor)
    get admin_edition_images_path(edition.id)
    assert_equal 302, status
    follow_redirect!
    assert_equal "/government/admin/publications/#{edition.id}/edit", path
  end

  test "forbids unauthorised users from viewing the images index endpoint" do
    edition = create(:draft_publication)
    user = create(:world_editor)
    user.permissions << "Preview images update"
    login_as user
    get admin_edition_images_path(edition.id)
    assert_equal 403, status
  end

  test "edit page displays alt text input for images with alt text" do
    login_authorised_user
    images = [build(:image)]
    edition = create(:draft_publication, images:)
    get edit_admin_edition_image_path(edition, images[0])
    assert_select "#image_alt_text"
  end

  test "edit page does not display alt text input where it is blank" do
    login_authorised_user
    images = [build(:image, alt_text: "")]
    edition = create(:draft_publication, images:)
    get edit_admin_edition_image_path(edition, images[0])
    assert_select "#image_alt_text", count: 0
  end

  test "#create redirects to #edit with a valid image upload" do
    login_authorised_user
    edition = create(:news_article)

    file = upload_fixture("images/960x640_jpeg.jpg")
    post admin_edition_images_path(edition), params: { image: { image_data: { file: } } }

    follow_redirect!
    assert_equal edit_admin_edition_image_path(edition, edition.images.last), path
  end

  test "#create shows the cropping page if image is too large" do
    login_authorised_user
    edition = create(:news_article)

    filename = "images/960x960_jpeg.jpg"
    post admin_edition_images_path(edition), params: { image: { image_data: { file: upload_fixture(filename, "image/jpeg") } } }

    assert_template "admin/edition_images/crop"
    assert_select "h1", "Crop image"

    img = document_root_element.css("img.app-c-image-cropper__image").first
    expected_data_url = "data:image/jpeg;base64,#{Base64.strict_encode64(file_fixture(filename).read)}"
    assert_equal expected_data_url, img["src"], "Expected img src to be a Data URL representation of the uploaded file"
  end

  test "#create shows a validation error if image is too small" do
    login_authorised_user
    edition = create(:news_article)

    file = upload_fixture("images/50x33_gif.gif")
    post admin_edition_images_path(edition), params: { image: { image_data: { file: } } }

    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file is too small. Select an image that is 960 pixels wide and 640 pixels tall"
  end

  test "#create shows a validation error if image has a duplicated filename" do
    login_authorised_user
    edition = create(:news_article)
    file = upload_fixture("images/960x640_gif.gif")
    create(:image, edition:, image_data: create(:image_data, file:))

    post admin_edition_images_path(edition), params: { image: { image_data: { file: } } }

    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name."
  end

  def login_authorised_user
    user = create(:gds_editor)
    user.permissions << "Preview images update"
    login_as user
  end
end
