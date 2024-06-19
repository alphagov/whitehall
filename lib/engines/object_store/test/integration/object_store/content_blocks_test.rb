require "test_helper"
require "capybara/rails"

class ContentBlocksTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "create a new email address" do
    visit new_object_store_content_blocks_path(block_type: "email_address")

    fill_in "content_block_properties_email_address", with: "example@example.com"
    find_button("Create Content block").click

    assert_text `email_address":"example@example.com"`
  end
end
