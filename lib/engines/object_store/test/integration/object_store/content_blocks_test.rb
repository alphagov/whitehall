require "test_helper"
require "capybara/rails"

class ContentBlocksTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    feature_flags = Flipflop::FeatureSet.current.test!
    feature_flags.switch!(:object_store, true)
  end

  test "successfully create a new email address" do
    visit new_object_store_content_block_editions_path(block_type: "email_address")

    fill_in "content_block_properties_email_address", with: "example@example.com"
    find_button("Create Content block").click

    assert_text '"email_address":"example@example.com"'
  end

  test "see error when creating invalid email address" do
    visit new_object_store_content_block_editions_path(block_type: "email_address")

    fill_in "content_block_properties_email_address", with: "e"
    find_button("Create Content block").click

    assert_text "error"
  end

  test "successfully create a new tax code" do
    visit new_object_store_content_block_editions_path(block_type: "tax_code")

    fill_in "content_block_properties_tax_code", with: "123"
    fill_in "content_block_properties_explanation", with: "An explanation"
    find_button("Create Content block").click

    assert_text '"tax_code":"123"'
  end

  test "see error when creating invalid tax code" do
    visit new_object_store_content_block_editions_path(block_type: "tax_code")

    fill_in "content_block_properties_tax_code", with: "1"
    find_button("Create Content block").click

    assert_text "error"
  end
end
