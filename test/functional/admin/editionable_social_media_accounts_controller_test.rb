require "test_helper"

class Admin::EditionableSocialMediaAccountsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :gds_editor
    @edition = create(:worldwide_organisation, :with_social_media_account, translated_into: [:cy])

    I18n.with_locale(:cy) do
      @edition.social_media_accounts.first.update!(
        title: "Translated title",
        url: "https://www.newurl.gov.cymru",
      )

      @worldwide_org_1 = create(:worldwide_organisation)
      @worldwide_org_2 = create(:worldwide_organisation)
      @wwo1_social_media_account = create(:social_media_account, socialable: @worldwide_org_1, ordering: 1)

      @access_limited_org = create(:worldwide_organisation, :access_limited_by_organisations)
      @access_limited_social_media_account = create(:social_media_account, socialable: @access_limited_org, ordering: 1)
      @allowed_user = create(:gds_editor, organisation: @access_limited_org.access_limiting_organisations.first)
    end
  end

  view_test "GET :index lists the existing social media accounts" do
    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "h2.govuk-summary-card__title", text: @edition.social_media_accounts.first.social_media_service.name

    assert_select "div.govuk-summary-list__row:nth-of-type(1) .govuk-summary-list__key", text: "English Account"
    assert_select "div.govuk-summary-list__row:nth-of-type(1) .govuk-summary-list__value", text: @edition.social_media_accounts.first.title

    assert_select "div.govuk-summary-list__row:nth-of-type(2) .govuk-summary-list__key", text: "Welsh Account"
    assert_select "div.govuk-summary-list__row:nth-of-type(2) .govuk-summary-list__value", text: "Translated title"
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

  view_test "GET :edit displays an existing social media account translation" do
    get :edit, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
      locale: "cy",
    }

    assert_response :success
    assert_select "select.govuk-select", value: @edition.social_media_accounts.first.social_media_service.name
    assert_select "input.govuk-input", value: "https://www.newurl.gov.cymru"
    assert_select "input.govuk-input", value: "Translated title"
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

  test "PATCH :update updates an existing social media account translation" do
    patch :update, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
      social_media_account: {
        title: "New translated title",
        url: "https://www.newurl.gov.cymru",
        locale: "cy",
      },
    }

    assert_response :redirect
    I18n.with_locale(:cy) do
      assert_equal "New translated title", @edition.social_media_accounts.first.title
      assert_equal "https://www.newurl.gov.cymru", @edition.social_media_accounts.first.url
    end
  end

  view_test "PATCH :update with invalid data shows errors" do
    patch :update, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
      social_media_account: {
        title: "New title",
        url: "www.invalid.gov.uk",
      },
    }

    assert_select ".govuk-error-summary"
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
    account = @edition.social_media_accounts.where(title: "Account title").first
    assert_equal "https://www.social.gov.uk", account.url
  end

  view_test "POST :create with invalid data shows errors" do
    post :create, params: {
      edition_id: @edition,
      social_media_account: {
        social_media_service_id: SocialMediaService.first,
        title: "Account title",
        url: "www.invalid.gov.uk",
      },
    }

    assert_select ".govuk-error-summary"
  end

  view_test "GET :confirm_destroy shows a confirmation before deletion" do
    get :confirm_destroy, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
    }

    assert_response :success
    assert_select "p.govuk-body", text: "Are you sure you want to delete \"#{@edition.social_media_accounts.first.title}\"?"
  end

  test "DELETE :destroy creates a social media account" do
    delete :destroy, params: {
      edition_id: @edition,
      id: @edition.social_media_accounts.first,
    }

    assert_response :redirect
    assert_empty @edition.social_media_accounts
  end

  view_test "GET :reorder displays the reorderable social media accounts" do
    edition = create(:worldwide_organisation)
    social_media_accounts = create_list(:social_media_account, 2, socialable: edition)
    get :reorder, params: { edition_id: edition.id }

    assert_response :success
    assert_select ".gem-c-reorderable-list__item", count: social_media_accounts.size
    assert_select "form" do
      assert_select "[action=?]", order_admin_edition_social_media_accounts_path(edition)
    end
  end

  test "PUT :order updates the ordering of social media accounts" do
    edition = create(:worldwide_organisation)
    social_media_account1 = create(:social_media_account, socialable: edition, ordering: 1)
    social_media_account2 = create(:social_media_account, socialable: edition, ordering: 2)

    put :order,
        params: { edition_id: edition.id,
                  ordering: {
                    social_media_account2.id.to_s => "1",
                    social_media_account1.id.to_s => "2",
                  } }

    assert_response :redirect
    assert_equal [social_media_account2, social_media_account1], edition.reload.social_media_accounts
  end

  test "GET social media account of another org cannot be fetched via a different organisation" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { edition_id: @worldwide_org_2.id, id: @wwo1_social_media_account.id }
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      get :confirm_destroy, params: { edition_id: @worldwide_org_2.id, id: @wwo1_social_media_account.id }
    end
  end

  test "PATCH social media account of another org cannot be updated via a different organisation" do
    assert_raises(ActiveRecord::RecordNotFound) do
      patch :update, params: {
        edition_id: @worldwide_org_2.id,
        id: @wwo1_social_media_account.id,
        social_media_account: {
          title: "Updated title",
          url: "https://www.example.com/bad",
          locale: "en",
        },
      }
    end
  end

  test "DELETE :social media accounts of another org cannot be destroyed via a different organisation" do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: {
        edition_id: @worldwide_org_2.id,
        id: @wwo1_social_media_account.id,
      }
    end
  end

  test "GET access limited orgs cannot have their social media accounts fetched by users from other orgs" do
    get :index, params: { edition_id: @access_limited_org.id }

    assert_response :forbidden
  end

  test "GET access limited orgs can have their social media accounts fetched by users from the allowed org" do
    login_as @allowed_user
    get :index, params: { edition_id: @access_limited_org.id }

    assert_response :ok
  end

  test "PATCH access limited orgs cannot have their social media accounts updated by users from other orgs" do
    patch :update, params: {
      edition_id: @access_limited_org.id,
      id: @access_limited_social_media_account.id,
      social_media_account: {
        title: "Updated title",
        url: "https://www.example.com/",
        locale: "en",
      },
    }

    assert_response :forbidden
  end

  test "PATCH access limited orgs can have their social media accounts updated by users from the allowed org" do
    login_as @allowed_user

    patch :update, params: {
      edition_id: @access_limited_org.id,
      id: @access_limited_social_media_account.id,
      social_media_account: {
        title: "Updated title",
        url: "https://www.example.com/",
        locale: "en",
      },
    }

    assert_response :redirect
  end

  test "DELETE access limited orgs cannot have their social media accounts deleted by users from other orgs" do
    delete :destroy, params: {
      edition_id: @access_limited_org.id,
      id: @access_limited_social_media_account.id,
    }

    assert_response :forbidden
  end

  test "DELETE access limited orgs can have their social media accounts deleted by users from the allowed org" do
    login_as @allowed_user

    delete :destroy, params: {
      edition_id: @access_limited_org.id,
      id: @access_limited_social_media_account.id,
    }

    assert_response :redirect
  end
end
