require "test_helper"
require "capybara/rails"

class ContentBlockEditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    login_as_admin
  end

  test "#index returns all Content Block Editions" do
    content_block_document = create(:content_block_document)
    create(
      :content_block_edition,
      details: '"email_address":"example@example.com"',
      content_block_document_id: content_block_document.id,
    )
    visit "/government/admin/content-object-store/content-block-editions"
    assert_text '"email_address":"example@example.com"'
  end
end
