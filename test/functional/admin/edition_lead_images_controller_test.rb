require "test_helper"

class Admin::EditionLeadImagesControllerTest < ActionController::TestCase
  test "PATCH :update successfully updates the lead image and republishes the draft edition" do
    login_as :writer

    image = build(:image)
    edition = create(:draft_case_study, images: [image])

    Whitehall::PublishingApi
    .expects(:save_draft)
    .with(edition)
    .returns(true)
    .once

    get :update, params: { edition_id: edition.id, id: image.id }

    assert_equal image, edition.reload.lead_image
    assert_redirected_to admin_edition_images_path(edition)
    assert_equal "Lead image updated to minister-of-funk.960x640.jpg", flash[:notice]
  end

  test "PATCH :update does not update the lead image when the edition is invalid " do
    login_as :writer

    published_edition = create(:published_case_study)
    image = build(:image)
    edition = create(:draft_case_study, images: [image], document: published_edition.document)

    edition.change_note = nil
    edition.save!(validate: false)

    Whitehall::PublishingApi
    .expects(:save_draft)
    .never

    get :update, params: { edition_id: edition.id, id: image.id }

    assert_nil edition.reload.lead_image
    assert_redirected_to admin_edition_images_path(edition)
    assert_equal "This edition is invalid: Change note can't be blank", flash[:alert]
  end

  test "PATCH :update forbids unauthorised users" do
    login_as :world_editor
    image = build(:image)
    edition = create(:draft_case_study, images: [image])

    get :update, params: { edition_id: edition.id, id: image.id }

    assert_response :forbidden
  end
end
