require 'test_helper'

class Admin::SocialMediaAccountsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
    @social_media_service = create(:social_media_service)
  end

  should_be_an_admin_controller

  test "POST on :create creates social media account" do
    worldwide_organisation = create(:worldwide_organisation)
    post :create, params: {
              social_media_account: {
          social_media_service_id: @social_media_service.id,
          url: "http://foo"
          },
          worldwide_organisation_id: worldwide_organisation
    }

    assert_redirected_to admin_worldwide_organisation_social_media_accounts_url(worldwide_organisation)
    assert_equal "#{@social_media_service.name} account created successfully", flash[:notice]
    assert_equal 1, worldwide_organisation.social_media_accounts.count
    assert_equal @social_media_service, worldwide_organisation.social_media_accounts.first.social_media_service
  end

  test "PUT on :update updates a social media account" do
    worldwide_organisation = create(:worldwide_organisation)
    social_media_account = worldwide_organisation.social_media_accounts.create(social_media_service_id: @social_media_service.id, url: "http://foo")

    put :update,
        params: {
          id: social_media_account,
          worldwide_organisation_id: worldwide_organisation,
          social_media_account: {
            social_media_service_id: @social_media_service.id,
            url: "http://bar"
          }
        }

    assert_redirected_to admin_worldwide_organisation_social_media_accounts_url(worldwide_organisation)
    assert_equal "#{social_media_account.service_name} account updated successfully", flash[:notice]
    assert_equal ["http://bar"], worldwide_organisation.social_media_accounts.map(&:url)
  end

  test ":create and :update strip whitespace from urls" do
    worldwide_organisation = create(:worldwide_organisation)
    post :create, params: { worldwide_organisation_id: worldwide_organisation, social_media_account: {
      social_media_service_id: @social_media_service.id,
      url: "http://foo "
    } }

    social_media_account = worldwide_organisation.social_media_accounts.first
    assert_equal "http://foo", social_media_account.url

    post :update, params: {
      id: social_media_account,
      worldwide_organisation_id: worldwide_organisation,
      social_media_account: {
        social_media_service_id: @social_media_service.id,
        url: "http://bar "
      }
    }
    assert_equal "http://bar", social_media_account.reload.url
  end

  test "DELETE on :destroy destroys the social media account" do
    organisation = create(:worldwide_organisation)
    social_media_account = create(:social_media_account, socialable: organisation)

    delete :destroy, params: { worldwide_organisation_id: organisation, id: social_media_account }

    assert_redirected_to admin_worldwide_organisation_social_media_accounts_url(organisation)
    assert_equal "#{social_media_account.service_name} account deleted successfully", flash[:notice]
    refute SocialMediaAccount.exists?(social_media_account.id)
  end
end
