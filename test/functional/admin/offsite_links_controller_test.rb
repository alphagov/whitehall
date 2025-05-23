require "test_helper"

class Admin::OffsiteLinksControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @world_location_news = build(:world_location_news)
    create(:world_location, world_location_news: @world_location_news)
    @offsite_link = create(:offsite_link, parent_type: "WorldLocationNews", parent: @world_location_news)
  end

  should_be_an_admin_controller

  view_test "GET :new should render new offsite links form" do
    get :new, params: { world_location_news_id: @world_location_news.slug }

    assert_select "h1", text: "Create a non-GOV.UK government link within ‘#{@world_location_news.name}’"

    assert_offsite_links_form(
      admin_world_location_news_offsite_links_path,
    )

    assert_select "label[for='offsite_link_url'] + .govuk-hint", text: "Must be a GOV.UK URL or a link ending in: - nhs.uk- royal.uk- victimandwitnessinformation.org.uk- beisgovuk.citizenspace.com- flu-lab-net.eu- tse-lab-net.eu"
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

    assert_select ".govuk-error-summary__body", text: "Please enter a valid alternative URL, such as https://www.nhs.uk/"
  end

  view_test "GET :edit should render existing offside links form" do
    get :edit, params: { world_location_news_id: @world_location_news.slug, id: @offsite_link.id }

    assert_select "h1", text: "Edit the offsite link within ‘#{@world_location_news.name}’"

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
