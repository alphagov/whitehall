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
  should_prevent_modification_of_unmodifiable :statistical_data_set
  should_allow_alternative_format_provider_for :statistical_data_set
  should_allow_overriding_of_first_published_at_for :statistical_data_set
  should_allow_scheduled_publication_of :statistical_data_set
  should_allow_access_limiting_of :statistical_data_set

  view_test "viewing a readonly representation of this edition" do
    statistical_data_set = create(:published_statistical_data_set)
    get :view, params: { id: statistical_data_set }

    assert_select "form#edit_edition fieldset[disabled='disabled']" do
      assert_select "textarea[name='edition[body]']"
    end
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
