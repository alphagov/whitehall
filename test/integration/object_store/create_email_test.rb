require "test_helper"
require "capybara/rails"

class CreateEmailTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    feature_flags = Flipflop::FeatureSet.current.test!
    feature_flags.switch!(:object_store, true)
    login_as_admin
  end

  test "allows an email object to be created" do
    visit new_admin_object_store_item_path(item_type: "email_address")

    fill_in "Title", with: "Some Title"
    fill_in "Email address", with: "foo@example.com"
    click_on "Save"

    created_object = ObjectStore::Item.find_by(title: "Some Title")

    assert_not_nil created_object
    assert created_object.email_address, "foo@example.com"
  end

  test "shows errors when missing fields blank" do
    visit new_admin_object_store_item_path(item_type: "email_address")

    click_on "Save"

    assert_text "Title can't be blank"
    assert_text "Email address can't be blank"
  end
end
