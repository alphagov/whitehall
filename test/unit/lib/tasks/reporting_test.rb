require "test_helper"
require "rake"

class ReportingRake < ActiveSupport::TestCase
  setup do
    @document_1 = create(:published_edition, body: "Some text 1")
    @document_2 = create(:draft_edition, body: "Some text 2")
    @document_3 = create(:published_edition, body: "Some other text 1")
  end

  teardown do
    Rake::Task["reporting:matching_docs"].reenable
  end

  test "it prints the content IDs of the matching documents from published editions" do
    assert_output(/#{@document_1.document.content_id}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
  end

  test "it does not print the content IDs of the matching documents from draft editions" do
    assert_output(/^(?!.*#{@document_2.document.content_id}).*$/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
  end

  test "it does not print the content IDs of the non-matching documents from published editions" do
    assert_output(/^(?!.*#{@document_3.document.content_id}).*$/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
  end
end
