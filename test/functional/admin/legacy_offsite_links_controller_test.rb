require "test_helper"

class Admin::LegacyOffsiteLinksControllerTest < ActionController::TestCase
  tests Admin::OffsiteLinksController

  setup do
    login_as :gds_editor
    @world_location_news = build(:world_location_news)
    create(:world_location, world_location_news: @world_location_news)
    @offsite_link = create(:offsite_link, parent_type: "WorldLocationNews", parent: @world_location_news)
  end

  should_be_an_admin_controller

  view_test "GET :new should render new offsite links form" do
    get :new, params: { world_location_news_id: @world_location_news.slug }

    assert_select "h2", text: "Create a non-GOV.UK government link within ‘#{@world_location_news.name}’"

    assert_offsite_links_form(
      admin_world_location_news_offsite_links_path,
    )
  end

  view_test "GET :edit should render existing offside links form" do
    get :edit, params: { world_location_news_id: @world_location_news.slug, id: @offsite_link.id }

    assert_select "h2", text: "Edit the offsite link within ‘#{@world_location_news.name}’"

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
      (1..3).each { |n| assert_select "div select[id=offsite_link_date_#{n}i]" }
      assert_select "div input[id=offsite_link_url]"

      assert_select "input[type=submit]"
    end
  end
end
