require 'test_helper'

class Admin::DocumentSourcesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "new form has url inputs" do
    edition = create(:draft_policy)

    get :new, edition_id: edition

    assert_select "form[action='#{admin_edition_document_sources_path(edition)}']" do
      assert_select "input[name='document_source[url]'][type='text']"
      assert_select "input[type='submit']"
    end
  end

  test "create should save a new document source" do
    edition = create(:draft_policy)

    post :create, edition_id: edition, document_source: {
      url: "http://woo.example.com"
    }

    assert_not_nil edition.document.document_source
    document_source = edition.document.document_source
    assert_equal "http://woo.example.com", document_source.url
    assert_redirected_to admin_policy_path(edition, anchor: 'document-sources')
  end

  test "create should allow errors to be corrected" do
    edition = create(:draft_policy)

    post :create, edition_id: edition, document_source: { url: "" }

    assert_response :success
    assert_nil edition.document.document_source
    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "document_source[url]"
    end
  end

end
