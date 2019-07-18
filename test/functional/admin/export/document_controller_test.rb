require 'test_helper'

class Admin::Export::DocumentControllerTest < ActionController::TestCase
  test "show responds with JSON representation of a document" do
    document = stub_record(:document, id: 1, slug: 'some-document')
    Document.stubs(:find).with(document.id.to_s).returns(document)

    get :show, params: { id: document.id }, format: 'json'
    assert_equal 'some-document', json_response['document']['slug']
  end
end
