require "test_helper"

class CorporateInformationPagesControllerTest < ActionController::TestCase
  include Rails.application.routes.url_helpers

  should_be_a_public_facing_controller

  view_test "show renders the summary as plain text" do
    @corporate_information_page = create(:published_worldwide_organisation_corporate_information_page, summary: "Just plain text")
    get :show, params: { worldwide_organisation_id: @corporate_information_page.worldwide_organisation.id, id: @corporate_information_page.slug }

    assert_select "p", text: "Just plain text"
  end

  view_test "show renders the body as govspeak" do
    @corporate_information_page = create(:published_worldwide_organisation_corporate_information_page, body: "## Title\n\npara1\n\n")
    get :show, params: { worldwide_organisation_id: @corporate_information_page.worldwide_organisation.id, id: @corporate_information_page.slug }

    assert_select ".body" do
      assert_select "h2", "Title"
      assert_select "p", "para1"
    end
  end

  view_test "should link to world location organisation belongs to" do
    world_location = create(:world_location)
    worldwide_organisation = create(:worldwide_organisation, world_locations: [world_location])
    corporate_information_page = create(:corporate_information_page, :published, worldwide_organisation:, organisation: nil)

    get :show, params: { organisation: nil, worldwide_organisation_id: worldwide_organisation, id: corporate_information_page.slug }

    assert_select "a[href=?]", worldwide_organisation.public_path
    assert_select "a[href=?]", world_location.public_path
  end
end
