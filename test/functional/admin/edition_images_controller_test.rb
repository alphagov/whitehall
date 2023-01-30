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
end
