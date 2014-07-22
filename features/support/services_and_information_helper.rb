require 'gds_api/test_helpers/rummager'

module ServicesAndInformationHelper
  include GdsApi::TestHelpers::Rummager

  def stub_rummager_response
    Whitehall.unified_search_client.stubs(:unified_search).returns(
      rummager_has_services_and_info_data_for_organisation
    )
  end

  def stub_empty_rummager_response
    Whitehall.unified_search_client.stubs(:unified_search).returns(
      rummager_has_no_services_and_info_data_for_organisation
    )
  end
end

World(ServicesAndInformationHelper)
