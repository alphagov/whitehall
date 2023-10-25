require "test_helper"

class Admin::TopicalEventsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  view_test "GET :show lists the topical event details" do
    topical_event = create(:topical_event)
    get :show, params: { id: topical_event }

    assert_response :success
    assert_select "h1", topical_event.name
  end

  view_test "GET :new renders topical event form" do
    get :new

    assert_response :success
    assert_select "input[name='topical_event[name]']"
  end

  test "POST :create saves the topical event" do
    assert_difference("TopicalEvent.count") do
      post :create, params: {
        topical_event: {
          name: "Event",
          description: "Event description",
          summary: "Event summary",
          logo_attributes: {
            file: upload_fixture("images/960x640_jpeg.jpg"),
          },
        },
      }
    end

    assert_response :redirect

    topical_event = TopicalEvent.last
    assert_equal "Event", topical_event.name
    assert_equal "Event description", topical_event.description
    assert topical_event.logo.present?
  end

  test "POST :create uses the file cache if present" do
    cached_logo = build(:featured_image_data, file: upload_fixture("images/960x640_jpeg.jpg"))

    post :create, params: {
      topical_event: {
        name: "Event",
        description: "Event description",
        summary: "Event summary",
        logo_attributes: {
          file_cache: cached_logo.file_cache,
        },
      },
    }

    topical_event = TopicalEvent.last
    assert_equal "960x640_jpeg.jpg", topical_event.logo.filename
  end

  test "POST :create discards the file cache if file is present" do
    cached_logo = build(:featured_image_data, file: upload_fixture("images/960x640_jpeg.jpg"))

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/960x640_jpeg.jpg/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/big-cheese.960x640.jpg/), anything, anything, anything, anything, anything).times(7)

    post :create, params: {
      topical_event: {
        name: "Event",
        description: "Event description",
        summary: "Event summary",
        logo_attributes: {
          file: upload_fixture("big-cheese.960x640.jpg"),
          file_cache: cached_logo.file_cache,
        },
      },
    }

    topical_event = TopicalEvent.last
    assert_equal "big-cheese.960x640.jpg", topical_event.logo.filename
  end

  test "GET :index lists the topical events" do
    topical_event_c = create(:topical_event, name: "Topic C")
    topical_event_a = create(:topical_event, name: "Topic A")
    topical_event_b = create(:topical_event, name: "Topic B")

    get :index

    assert_response :success
    assert_equal(assigns(:topical_events), [topical_event_a, topical_event_b, topical_event_c])
  end

  view_test "GET :index page has the View link to show page" do
    topical_event = create(:topical_event)
    get :index
    assert_select "a[href=?]", admin_topical_event_path(topical_event), text: /View/
  end

  view_test "GET :edit renders the topical event form" do
    topical_event = create(:topical_event)
    get :edit, params: { id: topical_event }

    assert_response :success
    assert_select "input[name='topical_event[name]'][value='#{topical_event.name}']"
  end

  view_test "GET :edit renders id for logo model if it exists" do
    topical_event = create(:topical_event, :with_logo)

    get :edit, params: { id: topical_event }

    expected_hidden_field_name = "topical_event[logo_attributes][id]"
    expected_hidden_field_value = topical_event.logo.id
    assert_select "input[name='#{expected_hidden_field_name}'][value='#{expected_hidden_field_value}']"
  end

  test "PUT :update saves changes to the topical event" do
    topical_event = create(:topical_event, :with_logo)
    logo = topical_event.logo

    logo.assets
        .pluck(:asset_manager_id)
        .map { |id| AssetManagerDeleteAssetWorker.expects(:perform_async).with(anything, id).once }

    put :update, params: {
      id: topical_event,
      topical_event: {
        name: "New name",
        logo_attributes: {
          id: logo.id,
          file: upload_fixture("images/960x640_jpeg.jpg"),
        },
      },
    }

    assert_response :redirect
    assert_equal "New name", topical_event.reload.name
    assert_equal logo.id, topical_event.reload.logo.id
    assert_equal "960x640_jpeg.jpg", topical_event.reload.logo.filename
  end

  test "PUT :update discards the file cache if file is present" do
    topical_event = create(:topical_event, :with_logo)
    cached_logo = build(:featured_image_data, file: upload_fixture("images/960x640_jpeg.jpg"))

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/960x640_jpeg.jpg/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/big-cheese.960x640.jpg/), anything, anything, anything, anything, anything).times(7)

    put :update, params: {
      id: topical_event,
      topical_event: {
        logo_attributes: {
          id: topical_event.logo.id,
          file: upload_fixture("big-cheese.960x640.jpg"),
          file_cache: cached_logo.file_cache,
        },
      },
    }

    topical_event = TopicalEvent.last
    assert_equal "big-cheese.960x640.jpg", topical_event.logo.filename
  end

  test "GET :confirm_destroy calls correctly" do
    topical_event = create(:topical_event)

    get :confirm_destroy, params: { id: topical_event.id }

    assert_response :success
    assert_equal topical_event, assigns(:topical_event)
  end

  test "DELETE :destroy deletes the topical event and dependent classes" do
    topical_event = create(:topical_event, :with_logo, :with_social_media_accounts)
    logo = topical_event.logo
    social_media_account = topical_event.social_media_accounts.first
    delete :destroy, params: { id: topical_event }

    assert_response :redirect
    assert_nil TopicalEvent.find_by(id: topical_event.id)
    assert_nil FeaturedImageData.find_by(id: logo.id)
    assert_nil SocialMediaAccount.find_by(id: social_media_account.id)
  end
end
