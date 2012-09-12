require "test_helper"

class CorporateInformationPagesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller

  test "show renders the summary as plain text" do
    @corporate_information_page = create(:corporate_information_page, summary: "Just plain text")
    get :show, organisation_id: @corporate_information_page.organisation, id: @corporate_information_page

    assert_select_object @corporate_information_page do
      assert_select ".summary", text: "Just plain text"
    end
  end

  test "show renders the body as govspeak" do
    @corporate_information_page = create(:corporate_information_page, body: "## Title\n\npara1\n\n")
    get :show, organisation_id: @corporate_information_page.organisation, id: @corporate_information_page

    assert_select_object @corporate_information_page do
      assert_select ".body" do
        assert_select "h2", "Title"
        assert_select "p", "para1"
      end
    end
  end

end