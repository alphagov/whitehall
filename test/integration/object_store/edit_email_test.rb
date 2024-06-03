require "test_helper"
require "capybara/rails"

class EditEmailTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    login_as_admin
  end

  test "allows an email object to be updated" do
    item = create(:object_store_item, item_type: "email_address", email_address: "foo@example.com")
    visit edit_admin_object_store_item_path(item_type: "email_address", id: item.id)

    fill_in "Email address", with: "bar@example.com"
    click_on "Save"

    item.reload

    assert item.email_address, "bar@example.com"
  end
end
