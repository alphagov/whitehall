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
end
