require 'test_helper'

class Admin::EditionWorldLocationsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :departmental_editor
  end

  test 'provides access to the published editions associated with the world location' do
    published_editions = []
    world_location = build(:world_location)
    world_location.expects(:published_edition_world_locations).returns(published_editions)
    stub_controller_world_location_fetching(world_location)

    get :index, world_location_id: 12

    assert_equal published_editions, assigns('editions')
  end

  test 'provides access to the featured edition world locations associated with the world location' do
    featured_edition_world_locations = []
    world_location = build(:world_location)
    world_location.expects(:featured_edition_world_locations).returns(featured_edition_world_locations  )
    stub_controller_world_location_fetching(world_location)

    get :index, world_location_id: 12

    assert_equal featured_edition_world_locations, assigns('featured_editions')
  end

  def stub_controller_world_location_fetching(with_world_location)
    @controller.stubs(:find_world_location)
    @controller.instance_eval { @world_location = with_world_location }
  end

  test "should build a new image ready for populating" do
    edition_world_location = create(:edition_world_location)

    get :edit, world_location_id: edition_world_location.world_location, id: edition_world_location

    assert assigns(:edition_world_location).image.is_a?(EditionWorldLocationImageData)
    assert assigns(:edition_world_location).image.new_record?
  end

  test "should mark the edition as featured" do
    edition_world_location = create(:edition_world_location, featured: "false")

    get :edit, world_location_id: edition_world_location.world_location, id: edition_world_location

    assert assigns(:edition_world_location).featured?
  end

  view_test "edit displays edition world_location fields" do
    edition_world_location = create(:edition_world_location)

    get :edit, world_location_id: edition_world_location.world_location, id: edition_world_location

    assert_select "form[action='#{admin_world_location_featuring_path(edition_world_location.world_location, edition_world_location)}']" do
      assert_select "input[type='hidden'][name='edition_world_location[featured]']"
      assert_select "input[type='file'][name='edition_world_location[image_attributes][file]']"
      assert_select "input[type='text'][name='edition_world_location[alt_text]']"
    end
  end

  test "should feature the edition for this world_location and store the featured image and alt text" do
    edition_world_location = create(:edition_world_location, featured: "false")

    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {
      featured: "true",
      alt_text: "new-alt-text",
      image_attributes: {
        file: fixture_file_upload('minister-of-funk.960x640.jpg')
      }
    }

    edition_world_location.reload
    assert edition_world_location.featured?
    assert_equal "new-alt-text", edition_world_location.alt_text
    assert_match /minister-of-funk/, edition_world_location.image.file.url
  end

  view_test "should display the form with errors if the edition world_location couldn't be saved" do
    edition_world_location = create(:edition_world_location)

    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {
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
    edition_world_location = create(:edition_world_location)

    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {
      featured: "true",
      alt_text: "new-alt-text",
      image_attributes: {}
    }

    assert_response :success
    assert_select '.form-errors'
  end

  view_test "should show the cached image file that was uploaded if the update fails" do
    edition_world_location = create(:edition_world_location)

    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {
      featured: "true",
      alt_text: nil,
      image_attributes: {
        file: fixture_file_upload('minister-of-funk.960x640.jpg')
      }
    }

    assert_select "form" do
      assert_select "input[name='edition_world_location[image_attributes][file_cache]'][value$='minister-of-funk.960x640.jpg']"
      assert_select ".already_uploaded", text: "minister-of-funk.960x640.jpg already uploaded"
    end
  end

  test "should build a new image ready for populating if the update fails" do
    edition_world_location = create(:edition_world_location)

    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {
      featured: "true",
      image_attributes: {}
    }

    assert assigns(:edition_world_location).image.is_a?(EditionWorldLocationImageData)
    assert assigns(:edition_world_location).image.new_record?
  end

  test "should allow unfeaturing of the edition world_location" do
    edition_world_location = create(:featured_edition_world_location)
    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {featured: "false"}
    edition_world_location.reload
    refute edition_world_location.featured?
    assert edition_world_location.image.blank?
    assert edition_world_location.alt_text.blank?
  end

  test "should redirect back to the index for this world locations featurings page" do
    world_location = create(:world_location)
    edition_world_location = create(:edition_world_location, world_location: world_location)
    post :update, world_location_id: edition_world_location.world_location, id: edition_world_location, edition_world_location: {}
    assert_redirected_to admin_world_location_featurings_path(world_location)
  end

  test "should prevent access to editon_world_locations of inaccessible editions" do
    protected_edition = stub("protected edition")
    protected_edition.stubs(:accessible_by?).with(@current_user).returns(false)
    edition_world_location = build(:edition_world_location)
    edition_world_location.stubs(:edition).returns(protected_edition)
    world_location = build(:world_location)
    world_location.edition_world_locations.stubs(:find).with("1").returns(edition_world_location)
    stub_controller_world_location_fetching(world_location)

    get :edit, world_location_id: '12', id: "1"
    assert_response 403
    get :update, world_location_id: '12', id: "1"
    assert_response 403
  end
end
