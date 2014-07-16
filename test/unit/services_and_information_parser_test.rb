require "test_helper"
require "gds_api/test_helpers/rummager"

class ServicesAndInformationParserTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Rummager

  test "#parse extracts content grouped by subsector from the Rummager API response" do
    content = rummager_has_services_and_info_data_for_organisation

    example_parsed_content_group = {
        title: "Waste",
        examples: [
            { "title" => "Register as a waste carrier, broker or dealer (England)",
              "link" => "/waste-carrier-or-broker-registration" },
            { "title" => "Hazardous waste producer registration (England and Wales)",
              "link" => "/hazardous-waste-producer-registration" },
            { "title" => "Check if you need an environmental permit",
              "link" => "/environmental-permit-check-if-you-need-one" },
            { "title" => "Classify different types of waste",
              "link" => "/how-to-classify-different-types-of-waste" }
        ],
        document_count: 49,
        subsector_link: "environmental-management/waste",
       }

    parsed_content = ServicesAndInformationParser.new(content).parse

    assert_equal example_parsed_content_group, parsed_content[0]
    assert_includes parsed_content, example_parsed_content_group
  end
end
