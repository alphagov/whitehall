require "test_helper"

class Admin::EditionImagesControllerTest < ActionController::TestCase
  setup do
    io_object = upload_fixture("minister-of-funk.960x640.jpg").tempfile.to_io
    stub_request(:get, %r{.*/media/.*/minister-of-funk.960x640.jpg}).to_return(status: 200, body: io_object, headers: {})
  end

  view_test "edit page shows image editing form" do
    login_authorised_user
    image = build(:image)
    edition = create(:draft_publication, images: [image])
    get :edit, params: { edition_id: edition.id, id: image.id }
    assert_select "form[action='#{admin_edition_image_path(edition, image)}'][method='post']"
  end

  view_test "edit page shows image if all its assets are uploaded" do
    login_authorised_user
    image = build(:image)
    edition = create(:draft_publication, images: [image])

    get :edit, params: { edition_id: edition.id, id: image.id }

    assert_select "img:match('src',?)", /.*data:image.*/
  end

  view_test "edit page shows processing label if some of the image assets haven't finished processing" do
    login_authorised_user
    image = build(:image_with_no_assets)
    edition = create(:draft_publication, images: [image])

    get :edit, params: { edition_id: edition.id, id: image.id }

    assert_select "span[class='govuk-tag govuk-tag--green']", text: "Processing", count: 1
  end

  test "#create renders #index with a valid image upload" do
    login_authorised_user
    edition = create(:news_article)

    file = upload_fixture("images/960x640_jpeg.jpg")
    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id).once

    post :create, params: { edition_id: edition.id, images: [{ image_data: { file: } }] }

    assert_template "admin/edition_images/index"
    assert_equal "Images successfully uploaded", flash[:notice]
  end

  test "#create updates the lead_image association if edition can have a custom lead image" do
    login_authorised_user
    edition = create(:news_article)

    file = upload_fixture("images/960x640_jpeg.jpg")
    post :create, params: { edition_id: edition.id, images: [{ image_data: { file: } }] }

    assert_equal "960x640_jpeg.jpg", edition.reload.lead_image.filename
  end

  view_test "#create shows a validation error if image is too small" do
    login_authorised_user
    edition = create(:news_article)

    file = upload_fixture("images/50x33_gif.gif")
    post :create, params: { edition_id: edition.id, images: [{ image_data: { file: } }] }

    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file is too small. Select an image that is at least 960 pixels wide and at least 640 pixels tall"
  end

  view_test "#create shows a validation error if image has a duplicated filename" do
    login_authorised_user
    edition = create(:news_article)
    file = upload_fixture("images/960x640_gif.gif")
    create(:image, edition:, image_data: build(:image_data, file:))

    post :create, params: { edition_id: edition.id, images: [{ image_data: { file: } }] }

    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name."
  end

  test "POST :create triggers a job be queued to store image and variants in Asset Manager" do
    login_authorised_user

    edition = create(:news_article)
    file = upload_fixture("images/960x640_jpeg.jpg")
    model_type = ImageData.to_s
    variants = Asset.variants.values

    AssetManagerCreateAssetWorker
      .expects(:perform_async)
      .with(anything, has_entries("assetable_id" => kind_of(Integer), "asset_variant" => any_of(*variants), "assetable_type" => model_type), anything, anything, anything, anything).times(7)

    post :create, params: { edition_id: edition.id, images: [{ image_data: { file: } }] }
  end

  test "DELETE :destroy when a lead image is present it deletes the edition_lead_image and sets a new lead image" do
    login_authorised_user
    image1 = build(:image)
    image2 = build(:image)
    edition = create(:draft_case_study, images: [image1, image2])
    create(:edition_lead_image, edition:, image: image1)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id).once

    delete :destroy, params: { edition_id: edition.id, id: image1.id }

    assert_equal 1, edition.reload.images.count
    assert_equal image2, edition.lead_image
    assert_redirected_to admin_edition_images_path(edition)
  end

  test "#create shows success message when all image assets are uploaded" do
    edition = create(:news_article)
    filename = "big-cheese.960x640.jpg"
    Services.asset_manager.stubs(:create_asset).returns({ "id" => "http://asset-manager/assets/some_asset_manager_id", "name" => filename })

    post :create, params: { edition_id: edition.id, images: [{ image_data: { file: upload_fixture(filename, "image/jpeg") } }] }
    AssetManagerCreateAssetWorker.drain

    assert_equal "Images successfully uploaded", flash[:notice]
  end

  def login_authorised_user
    user = create(:gds_editor)
    login_as user
  end
end
