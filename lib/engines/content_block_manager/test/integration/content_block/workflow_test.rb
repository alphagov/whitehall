require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::WorkflowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include SidekiqTestHelpers
  include ContentBlockManager::Engine.routes.url_helpers
  include ContentBlockManager::IntegrationTestHelpers

  let(:details) do
    {
      foo: "Foo text",
      bar: "Bar text",
    }
  end

  let(:organisation) { create(:organisation) }
  let(:document) { create(:content_block_document, :email_address, content_id: @content_id, title: "Some Title") }
  let(:edition) { create(:content_block_edition, document:, details:, organisation:, instructions_to_publishers: "instructions") }

  setup do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_request_for_schema("email_address")

    stub_publishing_api_has_embedded_content(content_id: @content_id, total: 0, results: [], order: ContentBlockManager::GetHostContentItems::DEFAULT_ORDER)
  end

  describe "when creating a new content block" do
    describe "when reviewing the changes" do
      let(:step) { ContentBlockManager::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:review] }

      describe "#show" do
        it "shows the new edition for review" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/review"
          assert_equal edition, assigns(:content_block_edition)
        end
      end

      describe "#update" do
        it "posts the new edition to the Publishing API and marks edition as published" do
          assert_edition_is_published do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:, is_confirmed: true)
          end
        end
      end
    end

    describe "when the edition details have not been confirmed" do
      let(:step) { ContentBlockManager::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:review] }

      describe "#update" do
        it "returns to the review page" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/review"
        end
      end
    end
  end

  describe "when updating an existing content block" do
    describe "when reviewing the links" do
      let(:step) { ContentBlockManager::ContentBlock::Editions::WorkflowController::UPDATE_BLOCK_STEPS[:review_links] }

      describe "#show" do
        it_returns_embedded_content do
          visit content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)
        end
      end

      describe "#update" do
        it "redirects to the next step" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :schedule_publishing)
        end
      end
    end

    describe "when scheduling or publishing" do
      let(:step) { ContentBlockManager::ContentBlock::Editions::WorkflowController::UPDATE_BLOCK_STEPS[:schedule_publishing] }

      describe "#show" do
        it "shows the form" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/schedule_publishing"
          assert_equal document, assigns(:content_block_document)
        end
      end

      describe "#update" do
        describe "when choosing to publish immediately" do
          it "shows the review page" do
            scheduled_at = {
              "scheduled_publication(1i)": "",
              "scheduled_publication(2i)": "",
              "scheduled_publication(3i)": "",
              "scheduled_publication(4i)": "",
              "scheduled_publication(5i)": "",
            }

            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
                params: {
                  schedule_publishing: "now",
                  scheduled_at:,
                }

            assert_template "content_block_manager/content_block/editions/workflow/review"
          end
        end

        describe "when scheduling publication" do
          it "shows the review page" do
            scheduled_at = {
              "scheduled_publication(1i)": "2024",
              "scheduled_publication(2i)": "01",
              "scheduled_publication(3i)": "01",
              "scheduled_publication(4i)": "12",
              "scheduled_publication(5i)": "00",
            }

            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:), params: {
              schedule_publishing: "schedule",
              scheduled_at:,
            }

            assert_template "content_block_manager/content_block/editions/workflow/review"
          end
        end

        describe "when leaving the schedule_publishing param blank" do
          it "shows an error message" do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

            assert_template "content_block_manager/content_block/editions/workflow/schedule_publishing"
            assert_match(/Schedule publishing cannot be blank/, response.body)
          end
        end
      end
    end
  end
end

def assert_edition_is_published(&block)
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
      content_id_alias: "some-title",
      instructions_to_publishers: "instructions",
      details: {
        "foo" => "Foo text",
        "bar" => "Bar text",
      },
      links: {
        primary_publishing_organisation: [organisation.content_id],
      },
      update_type: "major",
    },
  ]
  publishing_api_mock.expect :publish, fake_publish_content_response, [
    @content_id,
    "content_block",
  ]

  Services.stub :publishing_api, publishing_api_mock do
    block.call
    publishing_api_mock.verify
    document = ContentBlockManager::ContentBlock::Document.find_by!(content_id: @content_id)
    new_edition = ContentBlockManager::ContentBlock::Edition.find(document.live_edition_id)

    assert_equal document.live_edition_id, document.latest_edition_id

    assert_equal "published", new_edition.state
  end
end

def update_params(edition_id:, organisation_id:)
  {
    id: edition_id,
    schedule_publishing: "schedule",
    scheduled_at: {
      "scheduled_publication(3i)": "2",
      "scheduled_publication(2i)": "9",
      "scheduled_publication(1i)": "2024",
      "scheduled_publication(4i)": "10",
      "scheduled_publication(5i)": "05",
    },
    "content_block/edition": {
      creator: "1",
      details: { foo: "newnew@example.com", bar: "edited" },
      document_attributes: { block_type: "email_address", title: "Another email" },
      organisation_id:,
    },
  }
end
