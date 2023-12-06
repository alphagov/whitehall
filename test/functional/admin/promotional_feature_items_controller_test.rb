require "test_helper"

class Admin::PromotionalFeatureItemsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @promotional_feature = create(:promotional_feature)
    @organisation = @promotional_feature.organisation
  end

  should_be_an_admin_controller

  test "GET :new loads the organisation and feature and instantiates a new item and link" do
    get :new, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature }

    assert_response :success
    assert_template :new
    assert_equal @organisation, assigns(:organisation)
    assert_equal @promotional_feature, assigns(:promotional_feature)
    assert assigns(:promotional_feature_item).is_a?(PromotionalFeatureItem)
    assert_equal 1, assigns(:promotional_feature_item).links.size
  end

  test "POST :create saves the new promotional item to the feature" do
    post :create,
         params: {
           organisation_id: @organisation,
           promotional_feature_id: @promotional_feature,
           promotional_feature_item: {
             summary: "Summary text",
             image_alt_text: "Alt text",
             image: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
           },
         }

    assert promotional_feature_item = @promotional_feature.reload.promotional_feature_items.first
    assert_equal "Alt text", promotional_feature_item.image_alt_text
    assert_equal "minister-of-funk.960x640.jpg", promotional_feature_item.image.file.filename

    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, @promotional_feature)
    assert_equal "Feature item added.", flash[:notice]
  end

  test "POST :create re-renders new and builds link if none are present when the feature item does not save" do
    post :create, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature, promotional_feature_item: { summary: "" } }

    assert_template :new
    assert_equal 1, assigns(:promotional_feature_item).links.size
  end

  test "GET :edit loads the item and its links renders the template" do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)
    link = create(:promotional_feature_link, promotional_feature_item:)
    get :edit, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item }

    assert_response :success
    assert_template :edit
    assert_equal @organisation, assigns(:organisation)
    assert_equal @promotional_feature, assigns(:promotional_feature)
    assert_equal promotional_feature_item, assigns(:promotional_feature_item)
    assert_equal [link], assigns(:promotional_feature_item).links
  end

  test "GET :edit assigns a blank link if the item does not already have one" do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)
    get :edit, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item }

    assert_response :success
    assert_template :edit
    assert link = assigns(:promotional_feature_item).links.first
    assert link.new_record?
    assert link.is_a?(PromotionalFeatureLink)
  end

  test "PUT :update updates the item and does not delete the old image from the asset store" do
    link = create(:promotional_feature_link)
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature, links: [link])

    # We prefer to keep the image so that published docs can render it in case something goes wrong with the republishing.
    AssetManagerDeleteAssetWorker.expects(:perform_async).never

    put :update,
        params: { organisation_id: @organisation,
                  promotional_feature_id: @promotional_feature,
                  id: promotional_feature_item,
                  promotional_feature_item: {
                    summary: "Updated summary",
                    image_alt_text: "Alt text",
                    image: upload_fixture("big-cheese.960x640.jpg", "image/jpg"),
                    links_attributes: { "0" => { url: link.url, text: link.text, id: link.id, _destroy: false } },
                  } }

    assert_equal "Updated summary", promotional_feature_item.reload.summary
    assert_equal "big-cheese.960x640.jpg", promotional_feature_item.reload.image.file.filename
    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, @promotional_feature)
    assert_equal "Feature item updated.", flash[:notice]
  end

  test "PUT :update on a successful update does not delete the image from the asset store when a YouTube URL is provided and the user has the 'Add youtube urls to promotional features'" do
    @current_user.permissions << "Add youtube urls to promotional features"
    link = create(:promotional_feature_link)
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature, links: [link])

    # We prefer to keep the image assets in asset-manager so that published docs can render them,
    # in case the republishing is slow or unsuccessful.
    AssetManagerDeleteAssetWorker.expects(:perform_async).never

    put :update,
        params: { organisation_id: @organisation,
                  promotional_feature_id: @promotional_feature,
                  id: promotional_feature_item,
                  promotional_feature_item: {
                    summary: "Updated summary",
                    youtube_video_url: "https://www.youtube.com/watch?v=fFmDQn9Lbl4",
                    youtube_video_alt_text: "YouTube alt text.",
                    image_or_youtube_video_url: "youtube_video_url",
                    links_attributes: { "0" => { url: link.url, text: link.text, id: link.id, _destroy: false } },
                  } }
  end

  test "PUT :update re-renders edit and builds link if none are present when the feature item does not save" do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature, summary: "Old summary")
    put :update, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item, promotional_feature_item: { summary: "" } }

    assert_template :edit
    assert_equal "Old summary", promotional_feature_item.reload.summary
    assert_equal 1, assigns(:promotional_feature_item).links.size
  end

  test "DELETE :destroy deletes the promotional item and any image assets from asset-manager (if present)" do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)

    promotional_feature_item.assets.each do |asset|
      AssetManagerDeleteAssetWorker.expects(:perform_async).with(asset.asset_manager_id)
    end

    delete :destroy, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item }

    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, @promotional_feature)
    assert_not PromotionalFeatureItem.exists?(promotional_feature_item.id)
    assert_equal "Feature item deleted.", flash[:notice]
  end

  test "GET :confirm_destroy calls correctly" do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)
    get :confirm_destroy, params: { organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item }

    assert_response :success
    assert_equal promotional_feature_item, assigns(:promotional_feature_item)
  end

  test "POST: create - discards image_cache if image is present" do
    filename = "big-cheese.960x640.jpg"
    cached_promotional_feature_item = build(:promotional_feature_item)

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{filename}/), anything, anything, anything, anything, anything).times(7)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/minister-of-funk.960x640/), anything, anything, anything, anything, anything).never

    post :create,
         params: {
           organisation_id: @organisation,
           promotional_feature_id: @promotional_feature,
           promotional_feature_item: {
             summary: "Summary text",
             image_cache: cached_promotional_feature_item.image_cache,
             image: upload_fixture(filename, "image/png"),
           },
         }

    promotional_feature_item = PromotionalFeatureItem.last
    assert_equal "big-cheese.960x640.jpg", promotional_feature_item.image.file.filename
  end

  test "PUT: update - discards image_cache if image is present" do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature, summary: "Old summary")
    replacement_filename = "big-cheese.960x640.jpg"
    cached_filename = "example_fatality_notice_image.jpg"
    cached_promotional_feature_item = build(:promotional_feature_item, image: upload_fixture(cached_filename, "image/png"))

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{replacement_filename}/), anything, anything, anything, anything, anything).times(7)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{cached_filename}/), anything, anything, anything, anything, anything).never

    put :update, params: {
      organisation_id: @organisation,
      promotional_feature_id: @promotional_feature,
      id: promotional_feature_item.id,
      promotional_feature_item: {
        summary: "Summary text",
        image_cache: cached_promotional_feature_item.image_cache,
        image: upload_fixture(replacement_filename, "image/png"),
      },
    }

    promotional_feature_item = PromotionalFeatureItem.last
    assert_equal "big-cheese.960x640.jpg", promotional_feature_item.image.file.filename
  end
end
