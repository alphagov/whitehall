require "test_helper"

class Admin::StatisticalDataSetsControllerTest < ActionController::TestCase
  setup do
    StatisticalDataSet.stubs(access_limited_by_default?: false)
    login_as :writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :statistical_data_set
  should_allow_editing_of :statistical_data_set

  should_allow_lead_and_supporting_organisations_for :statistical_data_set
  should_allow_alternative_format_provider_for :statistical_data_set
  should_allow_overriding_of_first_published_at_for :statistical_data_set
  should_allow_scheduled_publication_of :statistical_data_set
  should_allow_access_limiting_of :statistical_data_set

  view_test "GET :new pre-selects organisation access limiting and pre-fills the creator's organisation for default-access-limited types when access_limiting_organisations_ui flag is on" do
    StatisticalDataSet.unstub(:access_limited_by_default?)
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    login_as create(:writer, organisation:)

    get :new

    assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
    assert_select "select[name='edition[access_limiting_organisation_ids][]']" do
      assert_select "option[selected='selected'][value='#{organisation.id}']"
    end
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
