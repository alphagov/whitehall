require "test_helper"

class Admin::ObjectStore::ItemsHelperTest < ActionView::TestCase
  include Admin::ObjectStore::ItemsHelper

  test "#edition_name returns the title for an edition" do
    edition = build(:object_store_item, item_type: "email_address")
    assert_equal edition_name(edition), "Email Address"
  end

  test "#partial_path should return a path for an edition" do
    edition = build(:object_store_item, item_type: "email_address")
    path = partial_path(edition, "form")
    assert_equal path, "admin/object_store/email_addresses/form"
  end

  test "#render_partial_path should render the correct path with the edition" do
    edition = build(:object_store_item, item_type: "email_address")
    partial_name = "form"

    expects(:render).with(partial: partial_path(edition, partial_name), object: edition, as: edition.item_type)

    render_partial_path(edition, partial_name)
  end

  test "#object_store_item_form renders a form" do
    edition = build(:object_store_item, item_type: "email_address")

    html = object_store_item_form(edition) do |_form|
      concat("Some text here")
    end

    assert_includes html, "Some text here"
    assert_includes html, form_url_for_object_store_item(edition)
    assert_includes html, render("govuk_publishing_components/components/button", {
      text: "Save",
      value: "save",
      name: "save",
      data_attributes: {
        module: "gem-track-click",
        "track-category": "form-button",
        "track-action": "object-store-item-button",
        "track-label": "Save",
      },
    })
  end
end
