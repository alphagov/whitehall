require "test_helper"

class ConfigurableDocumentTypeChangeTest < ActiveSupport::TestCase
  class PublishingApiClient
    attr_accessor :requests

    def initialize
      @requests = []
    end

    def patch_links(content_id, links)
      requests << { type: "patch_links", content_id: , links: }
    end

    def put_content(content_id, content)
      requests << { type: "put_content", content_id: , content: }
    end
  end

  class FailingPublishingApiClient < PublishingApiClient
    def patch_links(content_id, links)
      raise "failed to patch links"
    end
  end

  class LateFailingPublishingApiClient < PublishingApiClient
    def patch_links(content_id, links)
      if @requests.size > 3
        raise "failed to patch links"
      else
        super
      end
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

  setup do
    current_type = build_configurable_document_type("current_type", {
      "title" => "Current Type",
      "schema" => {
        "attributes" => {
          "body" => {
            "type" => "string"
          },
        },
      },
      "presenters" => {
        "publishing_api" => {
          "details" => {
            "body" => "govspeak",
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
    @edition = create(:draft_standard_edition, {
      configurable_document_type: "current_type",
      role_appointments:,
      lead_organisations: organisations,
      block_content: { "test_attribute" => "foo" },
    })
    I18n.with_locale(:fr) do
      @edition.block_content = { "test_attribute" => "bar" }
      @edition.save!
    end
  end

  test "it performs the type change successfully" do
    publishing_api_client = PublishingApiClient.new
    type_conversion = TestTypeConversion.new(@edition)
    type_change = StandardEdition::ConfigurableDocumentTypeChange.new(type_conversion, publishing_api_client)

    assert(type_change.apply)

    assert_equal("new_type", @edition.configurable_document_type)
    assert_empty(@edition.role_appointments)
    assert_edition_content_updated_before_conversion(@edition, publishing_api_client)
    assert_edition_links_patched_before_conversion(@edition, publishing_api_client)
    assert_edition_content_updated_after_conversion(@edition, publishing_api_client)
    assert_edition_links_patched_after_conversion(@edition, publishing_api_client)
  end

  test "it returns false if the operation fails before conversion takes place" do
    publishing_api_client = FailingPublishingApiClient.new
    type_conversion = TestTypeConversion.new(@edition)
    type_change = StandardEdition::ConfigurableDocumentTypeChange.new(type_conversion, publishing_api_client)

    assert_not(type_change.apply)
  end

  test "it returns true if the operation fails after conversion takes place" do
    publishing_api_client = LateFailingPublishingApiClient.new
    type_conversion = TestTypeConversion.new(@edition)
    type_change = StandardEdition::ConfigurableDocumentTypeChange.new(type_conversion, publishing_api_client)

    assert(type_change.apply)
  end

  def assert_edition_content_updated_before_conversion(edition, publishing_api_client)
    assert_equal("put_content", publishing_api_client.requests[0][:type])
    assert_equal(edition.content_id, publishing_api_client.requests[0][:content_id])
    assert_equal("en", publishing_api_client.requests[0][:content][:locale])
    assert_equal("put_content", publishing_api_client.requests[1][:type])
    assert_equal(edition.content_id, publishing_api_client.requests[1][:content_id])
    assert_equal("fr", publishing_api_client.requests[1][:content][:locale])
  end

  def assert_edition_links_patched_before_conversion(edition, publishing_api_client)
    assert_equal("patch_links", publishing_api_client.requests[2][:type])
    assert_equal(edition.content_id, publishing_api_client.requests[2][:content_id])
    assert_equal([], publishing_api_client.requests[2][:links][:people])
    assert_equal([], publishing_api_client.requests[2][:links][:roles])
  end

  def assert_edition_content_updated_after_conversion(edition, publishing_api_client)
    assert_equal("put_content", publishing_api_client.requests[3][:type])
    assert_equal(edition.content_id, publishing_api_client.requests[3][:content_id])
    assert_equal("en", publishing_api_client.requests[3][:content][:locale])
    assert_equal("put_content", publishing_api_client.requests[4][:type])
    assert_equal(edition.content_id, publishing_api_client.requests[4][:content_id])
    assert_equal("fr", publishing_api_client.requests[4][:content][:locale])
  end

  def assert_edition_links_patched_after_conversion(edition, publishing_api_client)
    assert_equal("patch_links", publishing_api_client.requests[5][:type])
    assert_equal(edition.content_id, publishing_api_client.requests[5][:content_id])
    assert_nil(publishing_api_client.requests[5][:links][:people])
    assert_nil(publishing_api_client.requests[5][:links][:roles])
  end
end