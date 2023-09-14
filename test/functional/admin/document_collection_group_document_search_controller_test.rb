require "test_helper"

class Admin::DocumentCollectionGroupDocumentSearchControllerTest < ActionController::TestCase
  extend Minitest::Spec::DSL

  let(:params) { { document_collection_id: collection, group_id: group } }
  let(:collection) { create(:document_collection, :with_group) }
  let(:group) { collection.groups.first }

  should_be_an_admin_controller

  test "GET #search_options renders search options" do
    login_as_preview_design_system_user :writer
    get(:search_options, params:)
    assert_template "document_collection_group_document_search/search_options"
  end

  test "GET #search_options blocks out users with no permissions" do
    login_as create(:writer)
    get(:search_options, params:)
    assert_template :forbidden
  end
end
