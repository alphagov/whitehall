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

  test "resolves internal Whitehall URLs in edition body with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    document = create(:document)
    create(:edition, document: document, body: body)

    linked_document = create(:document, slug: 'some-article')
    linked_edition = create(:published_edition, document: linked_document, state: 'published')

    Whitehall::AdminLinkLookup.stubs(:find_edition).with('/government/admin/news/2').returns(linked_edition)

    expected_whitehall_admin_links = [{
      "whitehall_admin_url" => "/government/admin/news/2",
      "public_url" => "www.test.gov.uk/government/generic-editions/some-article"
    }]

    login_as :export_data_user
    get :show, params: { id: document.id }, format: 'json'
    assert_equal expected_whitehall_admin_links, json_response['editions'][0]['whitehall_admin_links']
  end

  test "resolves internal Whitehall URLs in withdrawal explanation with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    edition = create(:withdrawn_edition)
    edition.unpublishing.update_attribute(:explanation, body)

    linked_document = create(:document, slug: 'some-article')
    linked_edition = create(:published_edition, document: linked_document, state: 'published')

    Whitehall::AdminLinkLookup.stubs(:find_edition).with('/government/admin/news/2').returns(linked_edition)

    expected_whitehall_admin_links = [{
      "whitehall_admin_url" => "/government/admin/news/2",
      "public_url" => "www.test.gov.uk/government/generic-editions/some-article"
    }]

    login_as :export_data_user
    get :show, params: { id: edition.document.id }, format: 'json'
    assert_equal expected_whitehall_admin_links, json_response['editions'][-1]['whitehall_admin_links']
  end

  test "appends the image url to the images response hash" do
    image = create(:image)
    publication = create(:publication, images: [image])

    login_as :export_data_user
    get :show, params: { id: publication.document.id }, format: 'json'
    images = json_response['editions'].first['associations']['images']

    assert_equal image.image_data.file_url, images.first['url']
  end
end
