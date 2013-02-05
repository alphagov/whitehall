require 'test_helper'

class Admin::SocialMediaAccountsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
    @social_media_service = create(:social_media_service)
  end

  should_be_an_admin_controller

  test "post create creates social_media_account" do
    worldwide_office = create(:worldwide_office)

    post :create, social_media_account: {
      social_media_service_id: @social_media_service.id,
      url: "http://foo"
      },
      socialable_type: "WorldwideOffice",
      socialable_id: worldwide_office.to_param

    puts css_select(".errors")

    assert_equal 1, worldwide_office.social_media_accounts.count
    assert_equal @social_media_service, worldwide_office.social_media_accounts.first.social_media_service
  end

  test "put update updates a social_media_account" do
    worldwide_office = create(:worldwide_office)
    social_media_account = worldwide_office.social_media_accounts.create(
      social_media_service_id: @social_media_service.id, url: "http://foo")

    put :update, social_media_account: {
      social_media_service_id: @social_media_service.id,
      url: "http://bar"
    }, id: social_media_account

    assert_equal ["http://bar"], worldwide_office.social_media_accounts.map(&:url)
  end
end