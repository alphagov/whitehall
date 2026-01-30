require "test_helper"
require "support/concerns/admin_edition_controller/creating_tests"
require "support/concerns/admin_edition_controller/edition_editing_tests"
require "support/concerns/admin_edition_controller/lead_and_supporting_organisations_tests"
require "support/concerns/admin_edition_controller/first_published_at_overriding_tests"
require "support/concerns/admin_edition_controller/alternative_format_provider_tests"
require "support/concerns/admin_edition_controller/access_limiting_tests"

class Admin::StatisticalDataSetsControllerTest < ActionController::TestCase
  setup do
    StatisticalDataSet.stubs(access_limited_by_default?: false)
    login_as :writer
  end

  include AdminEditionController::CreatingTests
  include AdminEditionController::EditionEditingTests
  include AdminEditionController::LeadAndSupportingOrganisationsTests
  include AdminEditionController::FirstPublishedAtOverridingTests
  include AdminEditionController::AlternativeFormatProviderTests
  include AdminEditionController::AccessLimitingTests

  should_be_an_admin_controller

  should_allow_scheduled_publication_of :statistical_data_set

private

  def edition_type
    :statistical_data_set
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
