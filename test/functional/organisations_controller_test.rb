require "test_helper"
require "gds_api/test_helpers/content_store"

class OrganisationsControllerTest < ActionController::TestCase
  include ApplicationHelper
  include GdsApi::TestHelpers::ContentStore

  should_be_a_public_facing_controller

  setup do
    stub_content_store_has_item(
      "/courts-tribunals",
      format: "special_route",
      title: "Court at midwicket",
    )
  end

  ### Describing :index ###
  test "index from the courts route renders the court index" do
    create(:organisation)
    court = create(:court)
    hmcts_tribunal = create(:hmcts_tribunal)

    get :index

    assert_template :courts_index
    assert_nil assigns(:organisations)
    assert_equal [court], assigns(:courts)
    assert_equal [hmcts_tribunal], assigns(:hmcts_tribunals)
  end

  view_test "links to the correct paths for courts and tribunals" do
    court = create(:court)
    hmcts_tribunal = create(:hmcts_tribunal)

    get :index

    assert_select "a[href='/courts-tribunals/#{court.slug}']", text: court.name
    assert_select "a[href='/courts-tribunals/#{hmcts_tribunal.slug}']", text: hmcts_tribunal.name
  end

  view_test "does not show a count of organisations for courts and tribunals" do
    create(:court)
    create(:hmcts_tribunal)

    get :index

    refute_select "span.count.js-filter-count"
  end
end
