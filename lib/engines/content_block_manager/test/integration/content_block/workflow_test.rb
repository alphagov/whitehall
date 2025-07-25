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
  let(:document) { create(:content_block_document, :pension, content_id: @content_id, sluggable_string: "some-slug") }
  let(:edition) { create(:content_block_edition, document:, details:, organisation:, instructions_to_publishers: "instructions", title: "Some Edition Title") }

  let!(:schema) { stub_request_for_schema("pension") }

  setup do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_publishing_api_has_embedded_content(content_id: @content_id, total: 0, results: [], order: ContentBlockManager::HostContentItem::DEFAULT_ORDER)
  end

  describe "when creating a new content block" do
    before do
      ContentBlockManager::ContentBlock::Document.any_instance.stubs(:is_new_block?).returns(true)
    end

    describe "when on the edit step" do
      let(:step) { :edit_draft }

      describe "#show" do
        it "shows the correct title and back link" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_equal assigns(:title), "Create #{schema.name}"
          assert_equal assigns(:back_path), content_block_manager.new_content_block_manager_content_block_document_path
        end
      end
    end

    describe "when reviewing the changes" do
      let(:step) { :review }

      describe "#show" do
        it "shows the new edition for review" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/review"
          assert_equal edition, assigns(:content_block_edition)
        end

        it "shows the correct context and confirmation text" do
          visit content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_text document.title
          assert_text "I confirm that the details I’ve put into the content block have been checked and are factually correct."
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
      let(:step) { :review }

      describe "#update" do
        it "returns to the review page" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/review"
        end
      end
    end

    describe "when subschemas are present" do
      let(:subschemas) do
        [
          stub("subschema_1", id: "subschema_1", name: "subschema_1", block_type: "subschema_1", embeddable_fields: [], fields: [stub("field", name: "name", data_attributes: nil)], group: nil),
          stub("subschema_2", id: "subschema_2", name: "subschema_2", block_type: "subschema_1", fields: [], group: nil),
        ]
      end

      let!(:schema) { stub_request_for_schema("pension", subschemas:) }

      describe "#show" do
        it "shows the form for the first subschema" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

          assert_template "content_block_manager/content_block/editions/workflow/embedded_objects"
        end

        it "shows the form for the second subschema" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_2")

          assert_template "content_block_manager/content_block/editions/workflow/embedded_objects"
        end

        describe "when there are existing subschema blocks created already" do
          let(:details) { { subschema_1: { existing_subschema: { name: "existing subschema" } } } }
          let(:edition) { create(:content_block_edition, document:, details:, organisation:, instructions_to_publishers: "instructions", title: "Some Edition Title") }

          it "shows the existing block and how to add another embedded block" do
            visit content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

            assert_text "existing subschema"
            assert_text "Add another subschema 1"
          end
        end
      end

      describe "#update" do
        it "redirects to the second subschema" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :embedded_subschema_2)
        end

        it "redirects to the review page" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_2")

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review)
        end
      end
    end
  end

  describe "when updating an existing content block" do
    before do
      ContentBlockManager::ContentBlock::Document.any_instance.stubs(:is_new_block?).returns(false)
    end

    describe "when editing an existing edition" do
      let(:step) { :edit_draft }

      describe "#show" do
        it "shows the form" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/edit_draft"
        end

        it "shows the correct title and back link" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_equal assigns(:title), "Change #{schema.name}"
          assert_equal assigns(:back_path), content_block_manager.content_block_manager_content_block_document_path(document)
        end
      end

      describe "#update" do
        it "updates the block and redirects to the next flow if editing an existing block" do
          ContentBlockManager::ContentBlock::Document.any_instance.stubs(:is_new_block?).returns(false)

          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "title" => "New title",
                  "organisation_id" => organisation.id,
                  "details" => {
                    "foo" => "bar",
                  },
                },
              }

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review_links)

          assert_equal edition.reload.title, "New title"
          assert_equal edition.reload.details["foo"], "bar"
          assert_equal edition.reload.details["bar"], "Bar text"
        end

        it "updates the block with nil if a details field is blank" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "title" => "New title",
                  "organisation_id" => organisation.id,
                  "details" => {
                    "foo" => "",
                  },
                },
              }

          assert_nil edition.reload.details["foo"]
        end

        it "updates the block and redirects to the review page if editing a new block" do
          ContentBlockManager::ContentBlock::Document.any_instance.stubs(:is_new_block?).returns(true)

          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "title" => "New title",
                  "organisation_id" => organisation.id,
                  "details" => {
                    "foo" => "bar",
                  },
                },
              }

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review)

          assert_equal edition.reload.title, "New title"
          assert_equal edition.reload.details["foo"], "bar"
          assert_equal edition.reload.details["bar"], "Bar text"
        end

        it "shows an error if a required field is blank" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "title" => "",
                  "details" => {
                    "foo" => "bar",
                  },
                },
              }

          assert_template "content_block_manager/content_block/editions/workflow/edit_draft"
          assert_match(/#{I18n.t('activerecord.errors.models.content_block_manager/content_block/edition.blank', attribute: 'Title')}/, response.body)
        end
      end
    end

    describe "when reviewing the links" do
      let(:step) { :review_links }

      describe "#show" do
        it_returns_embedded_content do
          visit content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)
        end

        describe "when there is no embedded content" do
          before do
            stub_publishing_api_has_embedded_content_for_any_content_id(
              results: [],
              total: 0,
              order: ContentBlockManager::HostContentItem::DEFAULT_ORDER,
            )
          end

          it "redirects to the next step" do
            get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :internal_note)
          end

          describe "when the request comes from the next step" do
            it "redirects to the previous step" do
              get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
                  headers: { "HTTP_REFERER" => "http://example.com#{content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: :internal_note)}" }

              assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :edit_draft)
            end
          end
        end
      end

      describe "#update" do
        it "redirects to the next step" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :internal_note)
        end
      end
    end

    describe "when updating the internal note" do
      let(:step) { :internal_note }

      describe "#show" do
        it "shows the form" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/internal_note"
        end
      end

      describe "#update" do
        it "adds the note and redirects" do
          change_note = "This is my note"
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "internal_change_note" => change_note,
                },
              }

          assert_equal edition.reload.internal_change_note, change_note

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :change_note)
        end
      end
    end

    describe "when updating the change note" do
      let(:step) { :change_note }

      describe "#show" do
        it "shows the form" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/change_note"
        end
      end

      describe "#update" do
        it "adds the note and redirects" do
          change_note = "This is my note"
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "major_change" => "1",
                  "change_note" => change_note,
                },
              }

          assert_equal edition.reload.change_note, change_note
          assert_equal edition.reload.major_change, true

          assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :schedule_publishing)
        end

        it "shows an error if the change is major and the change note is blank" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "major_change" => "1",
                  "change_note" => "",
                },
              }

          assert_match(/#{I18n.t('activerecord.errors.models.content_block_manager/content_block/edition.blank', attribute: 'Change note')}/, response.body)
        end

        it "shows an error if major_change is blank" do
          put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:),
              params: {
                "content_block/edition" => {
                  "major_change" => "",
                  "change_note" => "",
                },
              }

          assert_match(/#{I18n.t('activerecord.errors.models.content_block_manager/content_block/edition.attributes.major_change.inclusion')}/, response.body)
        end
      end

      describe "when subschemas are present" do
        let(:subschemas) do
          [
            stub("subschema", id: "subschema_1", name: "subschema_1", block_type: "subschema_1", group: nil),
            stub("subschema", id: "subschema_2", name: "subschema_2", block_type: "subschema_2", group: nil),
          ]
        end

        let!(:schema) { stub_request_for_schema("pension", subschemas:) }

        before do
          ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:has_entries_for_subschema_id?).returns(true)
        end

        describe "#show" do
          it "shows the form for the first subschema" do
            get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

            assert_template "content_block_manager/content_block/editions/workflow/embedded_objects"
          end

          it "shows the form for the second subschema" do
            get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_2")

            assert_template "content_block_manager/content_block/editions/workflow/embedded_objects"
          end
        end

        describe "#update" do
          it "redirects to the second subschema" do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :embedded_subschema_2)
          end

          it "redirects to review links" do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_2")

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review_links)
          end
        end
      end

      describe "when subschemas are present" do
        let(:group) { nil }
        let(:subschemas) do
          [
            stub("subschema", id: "subschema_1", name: "subschema_1", block_type: "subschema_1", group:, group_order: 0, fields: []),
            stub("subschema", id: "subschema_2", name: "subschema_2", block_type: "subschema_2", group:, group_order: 1, fields: []),
          ]
        end

        let!(:schema) { stub_request_for_schema("pension", subschemas:) }

        before do
          ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:has_entries_for_subschema_id?).returns(true)
        end

        describe "#show" do
          it "shows the form for the first subschema" do
            get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

            assert_template "content_block_manager/content_block/editions/workflow/embedded_objects"
          end

          it "shows the form for the second subschema" do
            get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_2")

            assert_template "content_block_manager/content_block/editions/workflow/embedded_objects"
          end
        end

        describe "#update" do
          it "redirects to the second subschema" do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_1")

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :embedded_subschema_2)
          end

          it "redirects to review links" do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_subschema_2")

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review_links)
          end
        end

        describe "when the subschemas are in a group" do
          let(:group) { "some_group" }

          before do
            schema.stubs(:subschemas_for_group).with(group).returns(subschemas)
          end

          describe "#show" do
            describe "when content exists for at least some of the subschemas" do
              let(:details) do
                {
                  subschemas[0].block_type.to_s => {
                    "item" => {
                      "key" => "value",
                    },
                  },
                }
              end

              it "shows the form for the group" do
                get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "group_some_group")

                assert_template "content_block_manager/content_block/editions/workflow/group_objects"
              end
            end

            describe "when content does not exist for any of the subschemas" do
              it "renders the select subschema group" do
                get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "group_some_group")

                assert_template "content_block_manager/content_block/shared/embedded_objects/select_subschema"
              end
            end
          end

          describe "#update" do
            it "redirects to review links" do
              put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "group_some_group")

              assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review_links)
            end
          end
        end
      end
    end

    describe "when scheduling or publishing" do
      let(:step) { :schedule_publishing }

      describe "#show" do
        it "shows the form" do
          get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

          assert_template "content_block_manager/content_block/editions/workflow/schedule_publishing"
          assert_equal document, assigns(:content_block_document)
        end
      end

      describe "#update" do
        describe "when choosing to publish immediately" do
          it "redirects to the review step" do
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

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review)
          end
        end

        describe "when scheduling publication" do
          it "redirects to the internal note page" do
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

            assert_redirected_to content_block_manager_content_block_workflow_path(id: edition.id, step: :review)
          end
        end

        describe "when leaving the schedule_publishing param blank" do
          it "shows an error message" do
            put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

            assert_template "content_block_manager/content_block/editions/workflow/schedule_publishing"
            assert_match(/#{I18n.t('activerecord.errors.models.content_block_manager/content_block/edition.attributes.schedule_publishing.blank')}/, response.body)
          end
        end
      end
    end

    describe "when on the review step" do
      let(:step) { :review }

      it "shows the correct context and confirmation text" do
        visit content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step:)

        assert_text document.title
        assert_text "I confirm that the details I’ve put into the content block have been checked and are factually correct."
      end
    end
  end

  describe "when an unknown step is provided" do
    describe "#show" do
      it "shows the new edition for review" do
        get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "some_random_step")

        assert_response :missing
      end
    end

    describe "#update" do
      it "posts the new edition to the Publishing API and marks edition as published" do
        put content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "some_random_step")

        assert_response :missing
      end
    end
  end

  describe "when an unknown subschema step is provided" do
    describe "#show" do
      it "returns a 404" do
        get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "embedded_something")

        assert_response :missing
      end
    end
  end

  describe "when an unknown group step is provided" do
    describe "#show" do
      it "returns a 404" do
        get content_block_manager.content_block_manager_content_block_workflow_path(id: edition.id, step: "group_something")

        assert_response :missing
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
      title: "Some Edition Title",
      content_id_alias: "some-slug",
      instructions_to_publishers: "instructions",
      details: {
        "foo" => "Foo text",
        "bar" => "Bar text",
      },
      links: {
        primary_publishing_organisation: [organisation.content_id],
      },
      update_type: "major",
      change_note: edition.change_note,
    },
  ]
  publishing_api_mock.expect :publish, fake_publish_content_response, [
    @content_id,
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
      document_attributes: { block_type: "pension", title: "Another email" },
      organisation_id:,
    },
  }
end
