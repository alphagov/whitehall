require "test_helper"
require "gds_api/test_helpers/rummager"

class ServicesAndInformationParserTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Rummager

  test "#parse extracts content grouped by subsector from the Rummager API response" do
    content = rummager_has_services_and_info_data_for_organisation
    expect_parsed_content_keys = [:title, :examples, :document_count, :subsector_link]

    parsed_content = ServicesAndInformationParser.new(content).parse

    assert_equal parsed_content[0].keys, expect_parsed_content_keys
  end
end
