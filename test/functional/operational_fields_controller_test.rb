require 'test_helper'

class OperationalFieldsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
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

  test "shows recent casualties" do
    iraq = create(:operational_field)
    fatality_notice = create(:published_fatality_notice, operational_field: iraq)
    casualty = create(:fatality_notice_casualty, fatality_notice: fatality_notice)

    get :show, id: iraq

    assert_select_object casualty
  end

  test "only shows title when there are no casualties" do
    iraq = create(:operational_field)
    fatality_notice = create(:published_fatality_notice, operational_field: iraq)

    get :show, id: iraq

    assert_select_object fatality_notice do
      assert_select ".summary a[href='#{public_document_url(fatality_notice)}']", text: fatality_notice.summary
      refute_select '.casualties'
    end
  end

  test "index displays a rudimentary index of fields (for url hackers)" do
    fields = [
      stub_record(:operational_field),
      stub_record(:operational_field),
      stub_record(:operational_field)
    ]
    OperationalField.stubs(:all).returns(fields)

    get :index

    assert_select ".fields-of-operation" do
      fields.each do |field|
        assert_select_object field do
          assert_select "a[href=#{operational_field_path(field)}]"
        end
      end
    end
  end
end
