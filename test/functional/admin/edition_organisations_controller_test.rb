require 'test_helper'

class Admin::EditionOrganisationsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :departmental_editor
  end

  test "should build a new image ready for populating" do
    edition_organisation = create(:edition_organisation)

    get :edit, id: edition_organisation

    assert assigns(:edition_organisation).image.is_a?(EditionOrganisationImageData)
    assert assigns(:edition_organisation).image.new_record?
  end

  test "should mark the edition as featured" do
    edition_organisation = create(:edition_organisation, featured: "false")

    get :edit, id: edition_organisation

    assert assigns(:edition_organisation).featured?
  end

  view_test "edit displays edition organisation fields" do
    edition_organisation = create(:edition_organisation)

    get :edit, id: edition_organisation

    assert_select "form[action='#{admin_edition_organisation_path(edition_organisation)}']" do
      assert_select "input[type='hidden'][name='edition_organisation[featured]']"
      assert_select "input[type='file'][name='edition_organisation[image_attributes][file]']"
      assert_select "input[type='text'][name='edition_organisation[alt_text]']"
    end
  end

  test "should feature the edition for this organisation and store the featured image and alt text" do
    edition_organisation = create(:edition_organisation, featured: "false")

    post :update, id: edition_organisation, edition_organisation: {
      featured: "true",
      alt_text: "new-alt-text",
      image_attributes: {
        file: fixture_file_upload('minister-of-funk.960x640.jpg')
      }
    }

    edition_organisation.reload
    assert edition_organisation.featured?
    assert_equal "new-alt-text", edition_organisation.alt_text
    assert_match /minister-of-funk/, edition_organisation.image.file.url
  end

  view_test "should display the form with errors if the edition organisation couldn't be saved" do
    edition_organisation = create(:edition_organisation)

    post :update, id: edition_organisation, edition_organisation: {
      featured: "true",
      alt_text: nil,
      image_attributes: {
        file: fixture_file_upload('minister-of-funk.960x640.jpg')
      }
    }

    assert_response :success
    assert_select '.form-errors'
  end

  view_test "should display the form with errors if the image couldn't be saved" do
    edition_organisation = create(:edition_organisation)

    post :update, id: edition_organisation, edition_organisation: {
      featured: "true",
      alt_text: "new-alt-text",
      image_attributes: {}
    }

    assert_response :success
    assert_select '.form-errors'
  end

  view_test "should show the cached image file that was uploaded if the update fails" do
    edition_organisation = create(:edition_organisation)

    post :update, id: edition_organisation, edition_organisation: {
      featured: "true",
      alt_text: nil,
      image_attributes: {
        file: fixture_file_upload('minister-of-funk.960x640.jpg')
      }
    }

    assert_select "form" do
      assert_select "input[name='edition_organisation[image_attributes][file_cache]'][value$='minister-of-funk.960x640.jpg']"
      assert_select ".already_uploaded", text: "minister-of-funk.960x640.jpg already uploaded"
    end
  end

  test "should build a new image ready for populating if the update fails" do
    edition_organisation = create(:edition_organisation)

    post :update, id: edition_organisation, edition_organisation: {
      featured: "true",
      image_attributes: {}
    }

    assert assigns(:edition_organisation).image.is_a?(EditionOrganisationImageData)
    assert assigns(:edition_organisation).image.new_record?
  end

  test "should allow unfeaturing of the edition organisation" do
    edition_organisation = create(:featured_edition_organisation)
    post :update, id: edition_organisation, edition_organisation: {featured: "false"}
    edition_organisation.reload
    refute edition_organisation.featured?
    assert edition_organisation.image.blank?
    assert edition_organisation.alt_text.blank?
  end

  test "should redirect back to the documents page of the organisation's admin page" do
    organisation = create(:organisation)
    edition_organisation = create(:edition_organisation, organisation: organisation)
    post :update, id: edition_organisation, edition_organisation: {}
    assert_redirected_to documents_admin_organisation_path(organisation)
  end

  test "should prevent access to editon_organisations of inaccessible editions" do
    protected_edition = stub("protected edition")
    protected_edition.stubs(:accessible_by?).with(@current_user).returns(false)
    edition_organisation = build(:edition_organisation)
    edition_organisation.stubs(:edition).returns(protected_edition)
    EditionOrganisation.stubs(:find).with("1").returns(edition_organisation)

    get :edit, id: "1"
    assert_response 403
    get :update, id: "1"
    assert_response 403
  end
end
