require "test_helper"

class Admin::OffsiteLinksControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @world_location_news = build(:world_location_news)
    create(:world_location, world_location_news: @world_location_news)
    @offsite_link = create(:offsite_link, world_location_news: [@world_location_news])
  end

  should_be_an_admin_controller

  view_test "GET :new should render new offsite links form" do
    get :new, params: { world_location_news_id: @world_location_news.slug }

    assert_select "h1", text: "Create an external link within ‘#{@world_location_news.name}’"

    assert_offsite_links_form(
      admin_world_location_news_offsite_links_path,
    )

    assert_select "label[for='offsite_link_url'] + .govuk-hint", text: "Must be a GOV.UK URL or a link ending in: - nhs.uk- royal.uk- victimandwitnessinformation.org.uk- energygovuk.citizenspace.com"
  end

  view_test "POST :create with bad data should show flash message" do
    post :create, params: {
      world_location_news_id: @world_location_news.slug,
      offsite_link: {
        title: "foo",
        summary: "barb",
        link_type: "blog_post",
        url: "bax",
      },
    }

    assert_select ".govuk-error-summary__body", text: "Url must be a valid URL, such as https://www.nhs.uk/"
  end

  view_test "GET :edit should render existing offside links form" do
    get :edit, params: { world_location_news_id: @world_location_news.slug, id: @offsite_link.id }

    assert_select "h1", text: "Edit the external link within '#{@world_location_news.name}'"

    assert_offsite_links_form(
      admin_world_location_news_offsite_link_path(id: @offsite_link.id),
    )

    assert_select "div input[id=offsite_link_title][value='#{@offsite_link.title}']"
  end

  test "PUT :update updates current offsite link" do
    form_param = { title: "Updated title" }

    put :update, params: {
      world_location_news_id: @world_location_news.slug, id: @offsite_link.id, offsite_link: form_param
    }

    assert_equal "Updated title", @offsite_link.reload.title
    assert_response :redirect
  end

  test "GET :confirm_destroy calls correctly" do
    get :confirm_destroy, params: { world_location_news_id: @world_location_news.slug, id: @offsite_link.id }

    assert_response :success
    assert_equal @offsite_link, assigns(:offsite_link)
  end

  test "DELETE :destroy removes offsite link" do
    assert_difference("OffsiteLink.count", -1) do
      delete :destroy, params: {
        world_location_news_id: @world_location_news.slug, id: @offsite_link.id
      }
    end

    assert_response :redirect
  end

  view_test "POST :create with valid data from standard edition should redirect to features page" do
    edition = create(:standard_edition, :published)
    post :create, params: {
      standard_edition_id: edition,
      offsite_link: {
        title: "foo",
        summary: "barb",
        link_type: "blog_post",
        url: "https://www.nhs.uk/",
      },
    }

    assert_response :redirect
  end

  view_test "POST :create with invalid data from standard edition should render form with errors" do
    edition = create(:standard_edition, :published)
    post :create, params: {
      standard_edition_id: edition,
      offsite_link: {
        title: "foo",
        summary: "barb",
        link_type: "blog_post",
        url: "bax",
      },
    }

    assert_response :success
    assert_select ".govuk-error-summary__body", text: "Url must be a valid URL, such as https://www.nhs.uk/"
  end

  view_test "POST :create with an invalid url should render form with errors" do
    edition = create(:standard_edition, :published)
    post :create, params: {
      standard_edition_id: edition,
      offsite_link: {
        title: "foo",
        summary: "barb",
        link_type: "blog_post",
        url: "http://[",
      },
    }

    assert_response :success
    assert_select ".govuk-error-summary__body", text: "Url must be a valid URL, such as https://www.nhs.uk/"
  end

  view_test "GET :new renders form for standard edition parent" do
    edition = create(:standard_edition, :published)
    get :new, params: { standard_edition_id: edition }

    assert_select "h1", text: "Create an external link within ‘#{edition.title}’"

    assert_offsite_links_form(
      admin_standard_edition_offsite_links_path(edition),
    )
  end

  view_test "GET :edit renders form for standard edition parent" do
    edition = create(:standard_edition, :published)
    offsite_link = create(:offsite_link, editions: [edition])
    get :edit, params: { standard_edition_id: edition, id: offsite_link.id }

    assert_select "h1", text: "Edit the external link within '#{edition.title}'"

    assert_offsite_links_form(
      admin_standard_edition_offsite_link_path(edition, offsite_link),
    )

    assert_select "div input[id=offsite_link_title][value='#{offsite_link.title}']"
  end

  test "PUT :update updates current offsite link for standard edition parent" do
    edition = create(:standard_edition, :published)
    offsite_link = create(:offsite_link, editions: [edition])
    form_param = { title: "Updated title" }

    put :update, params: {
      standard_edition_id: edition, id: offsite_link.id, offsite_link: form_param
    }
    assert_equal "Updated title", offsite_link.reload.title
    assert_response :redirect
  end

  view_test "GET :confirm_destroy renders confirmation for standard edition parent" do
    edition = create(:standard_edition, :published)
    offsite_link = create(:offsite_link, editions: [edition])
    get :confirm_destroy, params: { standard_edition_id: edition, id: offsite_link.id }

    assert_response :success
    assert_equal offsite_link, assigns(:offsite_link)
    assert_select "p", text: "Are you sure you want to delete \"#{offsite_link.title}\" from \"#{edition.title}\"?"
  end

  view_test "DELETE :destroy removes the association between an offsite link and an edition but does not delete the offsite link" do
    edition = create(:standard_edition, :published)
    offsite_link = create(:offsite_link, editions: [edition])

    assert_equal [offsite_link], edition.offsite_links
    assert_no_difference("OffsiteLink.count") do
      delete :destroy, params: {
        standard_edition_id: edition, id: offsite_link.id
      }
    end
    assert_response :redirect
  end

  test "cannot edit, update, confirm destroy or destroy an offsite link belonging to a different organisation" do
    organisation = create(:organisation)
    other_offsite_link = create(:offsite_link, title: "Original title", organisations: [create(:organisation)])
    params = { organisation_id: organisation.slug, id: other_offsite_link.id }

    assert_raise(ActiveRecord::RecordNotFound) { get :edit, params: }
    assert_raise(ActiveRecord::RecordNotFound) { get :confirm_destroy, params: }
    assert_raise(ActiveRecord::RecordNotFound) do
      put :update, params: params.merge(offsite_link: { title: "Not allowed" })
    end
    assert_no_difference("OffsiteLink.count") do
      assert_raise(ActiveRecord::RecordNotFound) { delete :destroy, params: }
    end

    assert_equal "Original title", other_offsite_link.reload.title
  end

  test "cannot update an offsite link belonging to a different edition" do
    edition = create(:standard_edition, :published)
    other_offsite_link = create(:offsite_link, title: "Original title", editions: [create(:standard_edition, :published)])

    assert_raise(ActiveRecord::RecordNotFound) do
      put :update, params: { standard_edition_id: edition, id: other_offsite_link.id, offsite_link: { title: "Not allowed" } }
    end

    assert_equal "Original title", other_offsite_link.reload.title
  end

  def assert_offsite_links_form(path)
    assert_select "form[action=?] div", path do
      assert_select "div input[id=offsite_link_title]"
      assert_select "div textarea[id=offsite_link_summary]"
      assert_select "div select[id=offsite_link_link_type]"
      (1..3).each { |n| assert_select "div input[id=offsite_link_date_#{n}i]" }
      assert_select "div input[id=offsite_link_url]"

      assert_select "button[type=submit]"
    end
  end
end
