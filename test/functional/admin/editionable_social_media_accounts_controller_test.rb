require "test_helper"

class Admin::EditionableSocialMediaAccountsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :gds_editor
    @edition = create(:editionable_worldwide_organisation, :with_social_media_account)
  end

  view_test "GET :index lists the existing social media accounts" do
    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "h2.govuk-summary-card__title", text: @edition.social_media_accounts.first.social_media_service.name
    assert_select "dd.govuk-summary-list__value", text: @edition.social_media_accounts.first.title
  end

  view_test "GET :edit displays an existing social media account" do
    get :edit, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
    }

    assert_response :success
    assert_select "select.govuk-select", value: @edition.social_media_accounts.first.social_media_service.name
    assert_select "input.govuk-input", value: @edition.social_media_accounts.first.url
    assert_select "input.govuk-input", value: @edition.social_media_accounts.first.title
  end

  test "PATCH :update updates an existing social media account" do
    patch :update, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
      social_media_account: {
        title: "New title",
        url: "https://www.newurl.gov.uk",
      },
    }

    assert_response :redirect
    assert_equal "New title", @edition.social_media_accounts.first.title
    assert_equal "https://www.newurl.gov.uk", @edition.social_media_accounts.first.url
  end

  test "POST :create creates a social media account" do
    post :create, params: {
      edition_id: @edition,
      social_media_account: {
        social_media_service_id: SocialMediaService.first,
        title: "Account title",
        url: "https://www.social.gov.uk",
      },
    }

    assert_response :redirect
    assert_equal "Account title", @edition.social_media_accounts.last.title
    assert_equal "https://www.social.gov.uk", @edition.social_media_accounts.last.url
  end
end
