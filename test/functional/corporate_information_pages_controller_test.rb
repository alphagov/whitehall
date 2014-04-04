require "test_helper"

class CorporateInformationPagesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  view_test "show renders the summary as plain text" do
    @corporate_information_page = create(:corporate_information_page, :published, summary: "Just plain text")
    get :show, organisation_id: @corporate_information_page.organisation, id: @corporate_information_page.slug

    assert_select ".description", text: "Just plain text"
  end

  view_test "show renders the body as govspeak" do
    @corporate_information_page = create(:corporate_information_page, :published, body: "## Title\n\npara1\n\n")
    get :show, organisation_id: @corporate_information_page.organisation, id: @corporate_information_page.slug

    assert_select ".body" do
      assert_select "h2", "Title"
      assert_select "p", "para1"
    end
  end

  view_test "should link to world location organisation belongs to" do
    world_location = create(:world_location)
    worldwide_organisation = create(:worldwide_organisation, world_locations: [world_location])
    corporate_information_page = create(:corporate_information_page, :published, worldwide_organisation: worldwide_organisation, organisation: nil)

    get :show, organisation: nil, worldwide_organisation_id: worldwide_organisation, id: corporate_information_page.slug

    assert_select "a[href=#{worldwide_organisation_path(worldwide_organisation)}]"
    assert_select "a[href=#{world_location_path(world_location)}]"
  end
end
