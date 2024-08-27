require "test_helper"
require "capybara/rails"

class ContentObjectStore::ContentBlock::WorkflowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SidekiqTestHelpers

  setup do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_request_for_schema("email_address")

    feature_flags.switch!(:content_object_store, true)
  end

  test "#publish posts the new edition to the Publishing API and marks edition as published" do
    details = {
      foo: "Foo text",
      bar: "Bar text",
    }

    organisation = create(:organisation)
    document = create(:content_block_document, :email_address, content_id: @content_id, title: "Some Title")
    edition = create(:content_block_edition, document:, details:, organisation:)

    fake_put_content_response = GdsApi::Response.new(
      stub("http_response", code: 200, body: {}),
    )
    fake_publish_content_response = GdsApi::Response.new(
      stub("http_response", code: 200, body: {}),
    )

    publishing_api_mock = Minitest::Mock.new
    publishing_api_mock.expect :put_content, fake_put_content_response, [
      @content_id,
      {
        schema_name: "content_block_type",
        document_type: "content_block_type",
        publishing_app: "whitehall",
        title: "Some Title",
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
        links: {
          primary_publishing_organisation: [organisation.content_id],
        },
      },
    ]
    publishing_api_mock.expect :publish, fake_publish_content_response, [
      @content_id,
      "major",
    ]

    Services.stub :publishing_api, publishing_api_mock do
      post content_object_store.publish_content_object_store_content_block_edition_path(id: edition.id), params: {
        id: edition.id,
      }
      publishing_api_mock.verify
      assert_equal "published", edition.reload.state
    end
  end

  test "#update schedules the publication of an edition" do
    organisation = create(:organisation)

    document = create(:content_block_document, :email_address, content_id: @content_id, title: "Some Title")

    edition = create(:content_block_edition, document:, organisation:)

    with_real_sidekiq do
      patch content_object_store.content_object_store_content_block_edition_path(edition), params: {
        id: edition.id,
        schedule_publishing: "schedule",
        scheduled_at: {
          "scheduled_publication(3i)": "2",
          "scheduled_publication(2i)": "9",
          "scheduled_publication(1i)": "2024",
          "scheduled_publication(4i)": "10",
          "scheduled_publication(5i)": "05",
        },
        content_block_edition: {
          creator: "1",
          details: { foo: "newnew@example.com", bar: "edited" },
          document_attributes: { block_type: "email_address", title: "Another email" },
          organisation_id: organisation.id,
        },
      }

      document = ContentObjectStore::ContentBlock::Document.find_by!(content_id: @content_id)
      new_edition = document.editions.last

      assert_equal Time.zone.local(2024, 9, 2, 10, 5, 0), new_edition.scheduled_publication
      assert_equal "scheduled", new_edition.state

      assert_equal 1, Sidekiq::ScheduledSet.new.size

      job = Sidekiq::ScheduledSet.new.first

      assert_equal job["args"].first, new_edition.id
      assert_equal job["queue"], "content_block_publishing"
      assert_equal job.at.to_i, new_edition.scheduled_publication.to_i
    end
  end
end

def stub_request_for_schema(block_type)
  schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema", body: {}, block_type:)
  ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type).with(block_type).returns(schema)
end
