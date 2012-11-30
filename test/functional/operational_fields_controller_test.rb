require 'test_helper'

class OperationalFieldsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  setup do
    @organisation = create(:organisation, handles_fatalities: true)
  end

  test "show displays name" do
    operational_field = create(:operational_field)

    get :show, id: operational_field

    assert_select ".page-header h1", text: %r{#{operational_field.name}}
  end

  test "shows description using govspeak" do
    operational_field = create(:operational_field, description: "description [with link](http://example.com).")

    get :show, id: operational_field

    assert_select ".description" do
      assert_select "a[href='http://example.com']", "with link"
    end
  end

  test "shows the first organisation found which handles fatalities" do
    get :show, id: create(:operational_field)
    assert_equal @organisation, assigns(:organisation)
  end

  test "assigns the published fatality notices for that field" do
    iraq = create(:operational_field)
    uk = create(:operational_field)

    iraq_fatality = create(:published_fatality_notice, operational_field: iraq)
    archived_iraq_fatality = create(:archived_fatality_notice, operational_field: iraq)

    uk_fatality = create(:fatality_notice, operational_field: uk)

    get :show, id: iraq
    assert_equal [FatalityNoticePresenter.new(iraq_fatality)], assigns(:fatality_notices)
  end
end
