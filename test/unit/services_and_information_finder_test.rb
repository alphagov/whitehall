require "test_helper"

class ServicesAndInformationFinderTest < ActiveSupport::TestCase
  test "#find searches rummager for the services and information for an org" do
    organisation = build_stubbed(:organisation)
    search_client = mock()
    expected_search_query = {
      filter_organisations: [organisation.name],
      facet_specialist_sectors: "1000,examples:4,example_scope:global",
    }

    finder = ServicesAndInformationFinder.new(organisation, search_client)
    search_client.expects(:unified_search).with(expected_search_query)

    finder.find
  end
end
