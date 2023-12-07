require "test_helper"

class Admin::TakePartPagesControllerTest < ActionController::TestCase
  setup do
    login_as(:gds_editor)
  end

  should_be_an_admin_controller

  test "GET :index fetches all the take part pages in order" do
    page3 = create(:take_part_page, ordering: 3)
    page1 = create(:take_part_page, ordering: 1)
    page2 = create(:take_part_page, ordering: 2)

    get :index

    assert_equal [page1, page2, page3], assigns(:take_part_pages)
    assert_response :success
    assert_template "index"
  end

  test "GET :new prepares an unsaved instance" do
    get :new

    assert assigns(:take_part_page).is_a? TakePartPage
    assert_not assigns(:take_part_page).persisted?
    assert_response :success
    assert_template "new"
  end

  test "POST :create saves a new instance with the supplied valid params" do
    take_part_page_attrs = attributes_for(:take_part_page, title: "Wear a monocle!")
                             .merge(
                               image_attributes: {
                                 file: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
                               },
                             )
    TakePartPage.expects(:patch_getinvolved_page_links).once

    post :create, params: { take_part_page: take_part_page_attrs }

    assert assigns(:take_part_page).persisted?
    assert_equal "Wear a monocle!", assigns(:take_part_page).title
    assert_equal "minister-of-funk.960x640.jpg", assigns(:take_part_page).image.filename
    assert_redirected_to admin_take_part_pages_path
  end

  test "POST :create doesn't save the new instance when the supplied params are invalid" do
    attrs = attributes_for(:take_part_page, title: "")
    TakePartPage.expects(:patch_getinvolved_page_links).never

    post :create, params: { take_part_page: attrs }

    assert_not assigns(:take_part_page).persisted?
    assert_response :success
    assert_template "new"
  end

  test "GET :edit fetches the supplied instance" do
    page = create(:take_part_page)

    get :edit, params: { id: page }

    assert_equal page, assigns(:take_part_page)
    assert_response :success
    assert_template "edit"
  end

  test "PUT :update changes the supplied instance with the supplied params" do
    attrs = attributes_for(:take_part_page, title: "Wear a monocle!")
    page = create(:take_part_page, title: "Drink in a gin palace!")
    image = page.image
    TakePartPage.expects(:patch_getinvolved_page_links).once

    post :update, params: {
      id: page,
      take_part_page: attrs.merge(
        image_attributes: {
          id: image.id,
          file: upload_fixture("images/960x640_jpeg.jpg", "image/jpg"),
        },
      ),
    }

    assert_equal page, assigns(:take_part_page)
    assert_equal "Wear a monocle!", page.reload.title
    assert_equal "960x640_jpeg.jpg", page.reload.image.filename
    assert_redirected_to admin_take_part_pages_path
  end

  test "PUT :update doesn't save the new instance when the supplied params are invalid" do
    attrs = attributes_for(:take_part_page, title: "")
    page = create(:take_part_page, title: "Drink in a gin palace!")
    TakePartPage.expects(:patch_getinvolved_page_links).never

    post :update, params: { id: page, take_part_page: attrs }

    assert_equal page, assigns(:take_part_page)
    assert_not_equal "", page.reload.title
    assert_equal "", assigns(:take_part_page).title
    assert_response :success
    assert_template "edit"
  end

  test "DELETE :destroy removes the supplied instance" do
    Services.asset_manager.stubs(:whitehall_asset).returns("id" => "http://asset-manager/assets/asset-id")
    page = create(:take_part_page)
    TakePartPage.expects(:patch_getinvolved_page_links).once

    delete :destroy, params: { id: page }

    assert_not TakePartPage.exists?(page.id)
    assert_redirected_to admin_take_part_pages_path
  end

  test "POST :reorder asks TakePartPage to reorder using the supplied ordering params and republishes the get involved page" do
    ordering_params = { "1" => "1", "4" => "2", "3" => "3", "2" => "4" }
    TakePartPage.expects(:reorder!).with(ordering_params, :ordering).once
    TakePartPage.patch_getinvolved_page_links

    post :reorder, params: {
      take_part_pages: {
        ordering: ordering_params,
      },
    }

    assert_redirected_to admin_take_part_pages_path
  end

  test "POST: create - discards image cache if file is present" do
    filename = "big-cheese.960x640.jpg"
    cached_image = build(:featured_image_data)

    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id", "name" => filename)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/minister-of-funk.960x640/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{filename}/), anything, anything, anything, anything, anything).times(7)

    post :create, params: {
      take_part_page:
        attributes_for(:take_part_page).merge(
          image_attributes: {
            file: upload_fixture(filename, "image/png"),
            file_cache: cached_image.file_cache,
          },
        ),
    }
  end

  test "PUT: update - discards image cache if file is present" do
    take_part_page = FactoryBot.create(:take_part_page)
    image = take_part_page.image

    replacement_filename = "example_fatality_notice_image.jpg"
    cached_filename = "big-cheese.960x640.jpg"
    cached_image = build(:featured_image_data, file: upload_fixture(cached_filename, "image/png"))

    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id", "name" => replacement_filename)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{replacement_filename}/), anything, anything, anything, anything, anything).times(7)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{cached_filename}/), anything, anything, anything, anything, anything).never

    put :update,
        params: {
          id: take_part_page.id,
          take_part_page: {
            image_attributes: {
              id: image.id,
              file: upload_fixture(replacement_filename, "image/png"),
              file_cache: cached_image.file_cache,
            },
          },
        }
  end
end
