require "test_helper"

class ConfigurableDocumentTypeChangeTest < ActiveSupport::TestCase
  class PublishingApiClient
    attr_accessor :requests

    def initialize
      @requests = []
    end

    def patch_links(content_id, links)
      requests << { content_id: , links: }
    end

    def put_content(content_id, content)
      requests << { content_id: , content: }
    end
  end

  class TestTypeConversion
    attr_reader :edition
    def initialize(edition)
      @edition = edition
    end

    def prepare
      @edition.role_appointments.clear
    end

    def convert
      @edition.configurable_document_type = "new_type"
    end
  end

  test "it performs the type change successfully" do
    current_type = build_configurable_document_type("current_type", {
      "title" => "Current Type",
      "schema" => {
        "attributes" => {
          "body" => {
            "type" => "string"
          },
          "test_attribute" => {
            "type" => "string"
          }
        },
      },
      "presenters" => {
        "publishing_api" => {
          "details" => {
            "body" => "govspeak",
            "test_attribute" => "raw",
          },
          "links" => [
            "ministerial_role_appointments",
          ]
        }
      },
      "settings" => { "configurable_document_group" => "group_type" }
    })
    new_type = build_configurable_document_type("new_type", {
      "title" => "Permitted Sibling Type",
      "schema" => {
        "attributes" => {
          "body" => {
            "type" => "string"
          }
        },
      },
      "presenters" => {
        "publishing_api" => {
          "details" => {
            "body" => "govspeak"
          },
          "links" => []
        }
      },
      "settings" => { "configurable_document_group" => "group_type" }
    })
    ConfigurableDocumentType.setup_test_types(current_type.merge(new_type))

    role_appointments = create_list(:ministerial_role_appointment, 2)
    organisations = create_list(:organisation, 2)
    edition = create(:draft_standard_edition, configurable_document_type: "current_type", role_appointments:, lead_organisations: organisations)

    publishing_api_client = PublishingApiClient.new
    type_conversion = TestTypeConversion.new(edition)
    type_change = StandardEdition::ConfigurableDocumentTypeChange.new(type_conversion, publishing_api_client)

    type_change.apply

    assert_equal("new_type", edition.configurable_document_type)
    assert_empty(edition.role_appointments)
    assert_nil(edition.block_content["test_attribute"])
    assert_empty(publishing_api_client.requests[0][:content][:details][:test_attribute])
    assert_equal([], publishing_api_client.requests[1][:links][:people])
    assert_equal([], publishing_api_client.requests[1][:links][:roles])
    assert_nil(publishing_api_client.requests[2][:links][:people])
    assert_nil(publishing_api_client.requests[2][:links][:roles])
  end
end