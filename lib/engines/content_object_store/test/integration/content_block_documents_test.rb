require "test_helper"
require "capybara/rails"

class ContentBlockEditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    login_as_admin

    feature_flags.switch!(:content_object_store, true)
  end

  test "when multiple editions exist for a document index returns only the latest edition" do
    content_block_document = create(:content_block_document, :email_address)
    first_edition = create(
      :content_block_edition,
      :email_address,
      details: { "email_address" => "first_edition@example.com" },
      content_block_document_id: content_block_document.id,
    )
    second_edition = create(
      :content_block_edition,
      :email_address,
      details: { "email_address" => "second_edition@example.com" },
      content_block_document_id: content_block_document.id,
    )

    visit content_object_store.content_object_store_content_block_documents_path

    assert_no_text first_edition.details["email_address"]
    assert_text second_edition.details["email_address"]
  end
end
