require "test_helper"
require "govuk-content-schema-test-helpers"

class PublishStaticPagesTest < ActiveSupport::TestCase
  test 'sends static pages to rummager and publishing api' do
    Whitehall::FakeRummageableIndex.any_instance.expects(:add).at_least_once.with(kind_of(Hash))
    publisher = PublishStaticPages.new
    expect_publishing(publisher.pages)

    PublishStaticPages.new.publish
  end

  test 'static pages presented to the publishing api are valid placeholders' do
    publisher = PublishStaticPages.new
    publisher.pages.each do |page|
      presented = publisher.present_for_publishing_api(page)
      expect_valid_placeholder(presented[:content])
    end
  end

  def expect_publishing(pages)
    pages.each do |page|
      Whitehall.publishing_api_v2_client.expects(:put_content)
        .with(
          page[:content_id],
          has_entries(
            document_type: page[:document_type],
            schema_name: "placeholder",
            base_path: page[:base_path],
            title: page[:title]
          )
        )

      Whitehall.publishing_api_v2_client.expects(:publish)
        .with(page[:content_id], 'minor', locale: "en")
    end
  end

  def expect_valid_placeholder(presented_page)
    validator = GovukContentSchemaTestHelpers::Validator.new(
      "placeholder",
      "schema",
      presented_page
    )
    assert validator.valid?, validator.errors.join("\n")
  end
end
