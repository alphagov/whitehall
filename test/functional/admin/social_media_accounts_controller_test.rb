require "test_helper"

class Admin::SocialMediaAccountsControllerTest < ActionController::TestCase
  setup do
    login_as :departmental_editor
    @social_media_service = create(:social_media_service)
  end

  should_be_an_admin_controller

  test "GET on :new returns forbidden response when user does not have correct permissions" do
    login_as :writer
    organisation = create(:organisation)
    get :new,
        params: {
          organisation_id: organisation,
        }

    assert_response :forbidden
  end

  test "POST on :create creates social media account" do
    organisation = create(:organisation)
    post :create,
         params: {
           social_media_account: {
             social_media_service_id: @social_media_service.id,
             url: "http://foo",
           },
           organisation_id: organisation,
         }

    assert_redirected_to admin_organisation_social_media_accounts_url(organisation)

    organisation.reload
    assert_equal "#{@social_media_service.name} account created successfully", flash[:notice]
    assert_equal 1, organisation.social_media_accounts.count
    assert_equal @social_media_service, organisation.social_media_accounts.first.social_media_service
  end

  test "POST on :create returns forbidden response when user does not have correct permissions" do
    login_as :writer
    organisation = create(:organisation)
    post :create,
         params: {
           social_media_account: {
             social_media_service_id: @social_media_service.id,
             url: "http://foo",
           },
           organisation_id: organisation,
         }

    assert_response :forbidden
  end

  test "GET on :edit returns forbidden response when user does not have correct permissions" do
    login_as :writer
    organisation = create(:organisation)
    social_media_account = organisation.social_media_accounts.create!(social_media_service_id: @social_media_service.id, url: "http://foo")
    get :edit,
        params: {
          id: social_media_account,
          organisation_id: organisation,
        }

    assert_response :forbidden
  end

  test "PUT on :update updates a social media account" do
    organisation = create(:organisation)
    social_media_account = organisation.social_media_accounts.create!(social_media_service_id: @social_media_service.id, url: "http://foo")

    put :update,
        params: {
          id: social_media_account,
          organisation_id: organisation,
          social_media_account: {
            social_media_service_id: @social_media_service.id,
            url: "http://bar",
          },
        }

    assert_redirected_to admin_organisation_social_media_accounts_url(organisation)
    assert_equal "#{social_media_account.service_name} account updated successfully", flash[:notice]

    organisation.reload
    assert_equal ["http://bar"], organisation.social_media_accounts.map(&:url)
  end

  test "PUT on :update returns forbidden response when user does not have correct permissions" do
    login_as :writer
    organisation = create(:organisation)
    social_media_account = organisation.social_media_accounts.create!(social_media_service_id: @social_media_service.id, url: "http://foo")
    post :update,
         params: {
           id: social_media_account,
           social_media_account: {
             social_media_service_id: @social_media_service.id,
             url: "http://bar",
           },
           organisation_id: organisation,
         }

    assert_response :forbidden
  end

  test ":create and :update strip whitespace from urls" do
    organisation = create(:organisation)
    post :create,
         params: { organisation_id: organisation,
                   social_media_account: {
                     social_media_service_id: @social_media_service.id,
                     url: "http://foo ",
                   } }

    social_media_account = organisation.reload.social_media_accounts.first
    assert_equal "http://foo", social_media_account.url

    post :update,
         params: {
           id: social_media_account,
           organisation_id: organisation,
           social_media_account: {
             social_media_service_id: @social_media_service.id,
             url: "http://bar ",
           },
         }
    assert_equal "http://bar", social_media_account.reload.url
  end

  test "GET on :confirm_destroy returns forbidden if user has insufficient permissions" do
    login_as :writer
    organisation = create(:organisation)
    social_media_account = create(:social_media_account, socialable: organisation)

    get :confirm_destroy, params: { organisation_id: organisation, id: social_media_account }

    assert_response :forbidden
  end

  view_test "GET on :confirm_destroy has the correct action and cancel links when socialable is an organisation" do
    organisation = create(:organisation)
    social_media_account = create(:social_media_account, socialable: organisation)

    get :confirm_destroy, params: { organisation_id: organisation, id: social_media_account }

    assert_select "form[action='#{admin_organisation_social_media_account_path(organisation, social_media_account)}']" do
      assert_select "a[href='#{admin_organisation_social_media_accounts_path(organisation)}']"
    end
  end

  test "DELETE on :destroy destroys the social media account" do
    organisation = create(:organisation)
    social_media_account = create(:social_media_account, socialable: organisation)

    delete :destroy, params: { organisation_id: organisation, id: social_media_account }

    assert_redirected_to admin_organisation_social_media_accounts_url(organisation)
    assert_equal "#{social_media_account.service_name} account deleted successfully", flash[:notice]
    assert_not SocialMediaAccount.exists?(social_media_account.id)
  end

  test "DELETE on :destroy returns forbidden when user has insufficient permissions" do
    login_as :writer
    organisation = create(:organisation)
    social_media_account = create(:social_media_account, socialable: organisation)

    delete :destroy, params: { organisation_id: organisation, id: social_media_account }

    assert_response :forbidden
  end

  view_test "GET on :index displays edit button only for languages the organisation is translated in" do
    organisation = create(:organisation, translated_into: %i[fr cy])
    social_media_account = create(:social_media_account, socialable_id: organisation.id, socialable_type: "Organisation")
    get :index, params: { organisation_id: organisation.id }
    assert_select "a[href=?]", edit_admin_organisation_social_media_account_path(organisation_id: organisation.slug, id: social_media_account.id, params: { locale: "en" })
    assert_select "a[href=?]", edit_admin_organisation_social_media_account_path(organisation_id: organisation.slug, id: social_media_account.id, params: { locale: "fr" })
    assert_select "a[href=?]", edit_admin_organisation_social_media_account_path(organisation_id: organisation.slug, id: social_media_account.id, params: { locale: "cy" })
    refute_select "a[href=?]", edit_admin_organisation_social_media_account_path(organisation_id: organisation.slug, id: social_media_account.id, params: { locale: "dk" })
  end

  view_test "GET on :index includes create button for users with sufficient permission to create social media accounts" do
    organisation = create(:organisation)
    get :index, params: { organisation_id: organisation.id }
    assert_select "a", text: "Create new account"
  end

  view_test "GET on :index omits create button for users without sufficient permission to create social media accounts" do
    login_as(:writer)
    organisation = create(:organisation)
    get :index, params: { organisation_id: organisation.id }
    assert_select "a", text: "Create new account", count: 0
  end

  test "PUT on :update with a locale updates only the translation of the social media account" do
    organisation = create(:organisation, translated_into: [:cy])
    social_media_account = organisation.social_media_accounts.create!(social_media_service_id: @social_media_service.id, url: "http://english-url.com", title: "Title in English")

    put :update,
        params: {
          id: social_media_account,
          organisation_id: organisation,
          social_media_account: {
            url: "http://welsh-url.cy",
            title: "Title in Welsh",
            locale: "cy",
          },
        }

    I18n.with_locale(:en) do
      assert_equal "http://english-url.com", social_media_account.reload.url
      assert_equal "Title in English", social_media_account.reload.title
    end

    I18n.with_locale(:cy) do
      assert_equal "http://welsh-url.cy", social_media_account.reload.url
      assert_equal "Title in Welsh", social_media_account.reload.title
    end
  end
end
