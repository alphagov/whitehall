require "test_helper"

class Admin::EditionLeadImagesControllerTest < ActionController::TestCase
  test "PATCH :update successfully updates the lead image and republishes the draft edition" do
    login_as :writer

    image = build(:image)
    edition = create(:draft_case_study, images: [image])

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id).once

    get :update, params: { edition_id: edition.id, id: image.id }

    assert_equal image, edition.reload.lead_image
    assert_redirected_to admin_edition_images_path(edition)
    assert_equal "Lead image updated to minister-of-funk.960x640.jpg", flash[:notice]
  end

  test "PATCH :update does not update the lead image when the edition is invalid" do
    login_as :writer

    published_edition = create(:published_case_study)
    image = build(:image)
    edition = create(:draft_case_study, images: [image], document: published_edition.document)

    edition.change_note = nil
    edition.save!(validate: false)

    get :update, params: { edition_id: edition.id, id: image.id }

    assert_nil edition.reload.lead_image
    assert_redirected_to admin_edition_images_path(edition)
    assert_equal "This edition is invalid: Change note cannot be blank", flash[:alert]
  end

  test "PATCH :update does not update the lead image when edition's body contains the images markdown" do
    login_as :writer

    published_edition = create(:published_case_study)
    image = build(:image)
    edition = create(:draft_case_study, images: [image], document: published_edition.document, body: "!!1")

    get :update, params: { edition_id: edition.id, id: image.id }

    assert_nil edition.reload.lead_image
    assert_redirected_to admin_edition_images_path(edition)
    assert_equal "This edition is invalid: Body cannot have a reference to the lead image in the text", flash[:alert]
  end
end
