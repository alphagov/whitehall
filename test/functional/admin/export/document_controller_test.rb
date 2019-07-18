require 'test_helper'

class Admin::Export::DocumentControllerTest < ActionController::TestCase
  test "show responds with JSON representation of a document" do
    document = stub_record(:document, id: 1, slug: 'some-document')
    Document.stubs(:find).with(document.id.to_s).returns(document)

    login_as :export_data_user
    get :show, params: { id: document.id }, format: 'json'
    assert_equal 'some-document', json_response['document']['slug']
  end

  test "shows forbidden if user does not have export data permission" do
    login_as :world_editor
    get :show, params: { id: '1' }, format: 'json'
    assert_response :forbidden
  end
end
