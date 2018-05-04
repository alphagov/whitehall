require "test_helper"
require "govuk-content-schema-test-helpers"

class PublishOrganisationsIndexPageTest < ActiveSupport::TestCase
  test 'sends the page to publishing api' do
    publisher = PublishOrganisationsIndexPage.new
    expect_publishing(publisher.send(:present_for_publishing_api))

    PublishOrganisationsIndexPage.new.publish
  end

  test 'the page presented to the publishing api is valid according to the relevant schema' do
    publisher = PublishOrganisationsIndexPage.new
    presented = publisher.send(:present_for_publishing_api)
    expect_valid_for_schema(presented[:content])
  end

  def expect_publishing(page)
    Services.publishing_api.expects(:put_content)
      .with(
        page[:content_id],
        has_entries(
          document_type: page[:content][:document_type],
          schema_name: page[:content][:schema_name],
          base_path: page[:content][:base_path],
          title: page[:content][:title],
          update_type: "minor",
        )
      )

    Services.publishing_api.expects(:publish)
      .with(page[:content_id], nil, locale: "en")
  end

  def expect_valid_for_schema(presented_page)
    validator = GovukContentSchemaTestHelpers::Validator.new(
      presented_page[:schema_name],
      "schema",
      presented_page
    )
    assert validator.valid?, validator.errors.join("\n")
  end
end
