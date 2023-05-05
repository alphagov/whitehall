require "test_helper"

class DraftDocumentCollectionWriteRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include SpecialistTopicHelper

  teardown do
    task.reenable
  end

  describe "Create draft document collection" do
    let(:task) { Rake::Task["create_draft_document_collection"] }

    test "it raises an error if args are missing" do
      assert_raise { task.invoke("my_email@email.com") }
      assert_raise { task.invoke(stub_valid_specialist_topic) }
    end

    test "it builds a draft document collection in the Whitehall database" do
      stub_valid_specialist_topic
      create(:user, email: "my_email@email.com")
      create(:organisation, name: "Government Digital Service")
      create(:document, content_id: whitehall_document_content_id, document_type: "detailed_guide")
      create(:edition, :published, type: "DetailedGuide", document_id: Document.last.id)

      capture_io { task.invoke(specialist_topic_base_path, "my_email@email.com") }

      assert_equal 1, DocumentCollection.count
    end

    test "will update an existing draft document collection" do
      create(:user, email: "my_email@email.com")
      create(:organisation, name: "Government Digital Service")
      create(:document, content_id: whitehall_document_content_id, document_type: "detailed_guide")
      create(:edition, :published, type: "DetailedGuide", document_id: Document.last.id)

      stub_valid_specialist_topic

      capture_io { task.invoke(specialist_topic_base_path, "my_email@email.com") }
      task.reenable

      new_document_content_id = "abc436e5-1234-4462-913f-9a497f7e793e"
      create(:document, content_id: new_document_content_id, document_type: "detailed_guide")
      create(:edition, :published, type: "DetailedGuide", document_id: Document.last.id)
      stub_publishing_api_has_item(
        specialist_topic_content_item
        .deep_merge(
          {
            "details": {
              "groups": [
                "name": "Foo",
                "content_ids": [new_document_content_id],
              ],
            },
          },
        ),
      )

      Timecop.travel 1.minute.from_now
      capture_io { task.invoke(specialist_topic_base_path, "my_email@email.com") }

      assert_equal 1, DocumentCollection.count
    end

    test "does not write a draft document collection if any operation fails" do
      create(:user, email: "my_email@email.com")
      create(:organisation, name: "Government Digital Service")

      unknown_document_content_id = "10e436e5-1234-4462-913f-9a497f7e793e"
      stub_publishing_api_has_item({
        content_id: unknown_document_content_id,
        base_path: "/i-have-not-been-stubbed",
      })

      stub_publishing_api_has_lookups(specialist_topic_base_path => specialist_topic_content_id)

      stub_publishing_api_has_item({
        "base_path": specialist_topic_base_path,
        "content_id": specialist_topic_content_id,
        "description": "something",
        "details": {
          "groups": [
            "name": "Foo",
            "content_ids": [unknown_document_content_id],
          ],
        },
      })

      stub_publishing_api_has_links({
        "content_id" => specialist_topic_content_id,
        "links" => level_two_topic_links,
      })

      assert_raise { capture_io { task.invoke(specialist_topic_base_path, "my_email@email.com") } }
      assert_equal 0, DocumentCollection.count
    end
  end
end
