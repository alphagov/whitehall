require "test_helper"

class Admin::RepublishingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  view_test "GDS Admin users should be able to acess the GET :index and see links to republishable documents" do
    create(:ministerial_role, name: "Prime Minister", cabinet_member: true)

    get :index

    assert_select ".govuk-table__cell:nth-child(1) a[href='https://www.test.gov.uk/government/history/past-prime-ministers']", text: "Past Prime Ministers"
    assert_select ".govuk-table__cell:nth-child(2) a[href='#']", text: "Republish 'Past Prime Ministers' page"
    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to access the GET :index" do
    login_as :writer

    get :index
    assert_response :forbidden
  end
end
