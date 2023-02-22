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
    images = [build(:image)]
    edition = create(:draft_publication, images:)
    user = create(:gds_editor)
    user.permissions << "Preview images update"
    login_as user
    get edit_admin_edition_image_path(edition, images[0])
    assert_select "#image_alt_text"
  end

  test "edit page does not display alt text input where it is blank" do
    images = [build(:image, alt_text: "")]
    edition = create(:draft_publication, images:)
    user = create(:gds_editor)
    user.permissions << "Preview images update"
    login_as user
    get edit_admin_edition_image_path(edition, images[0])
    assert_select "#image_alt_text", count: 0
  end
end
