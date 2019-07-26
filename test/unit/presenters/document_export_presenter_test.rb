require 'test_helper'

class DocumentExportPresenterTest < ActiveSupport::TestCase
  test "resolves internal Whitehall URLs in edition body with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    document = create(:document)
    create(:edition, document: document, body: body)

    linked_document = create(:document, slug: 'some-article')
    linked_edition = create(:published_edition, document: linked_document, state: 'published')

    Whitehall::AdminLinkLookup.stubs(:find_edition).with('/government/admin/news/2').returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "www.test.gov.uk/government/generic-editions/some-article"
    }]

    result = DocumentExportPresenter.new(document).as_json
    assert_equal expected_whitehall_admin_links, result[:editions][0][:whitehall_admin_links]
  end

  test "resolves internal Whitehall URLs in withdrawal explanation with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    edition = create(:withdrawn_edition)
    edition.unpublishing.update_attribute(:explanation, body)

    linked_document = create(:document, slug: 'some-article')
    linked_edition = create(:published_edition, document: linked_document, state: 'published')

    Whitehall::AdminLinkLookup.stubs(:find_edition).with('/government/admin/news/2').returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "www.test.gov.uk/government/generic-editions/some-article"
    }]

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal expected_whitehall_admin_links, result[:editions][-1][:whitehall_admin_links]
  end

  test "appends the image url to the images response hash" do
    image = create(:image)
    publication = create(:publication, images: [image])

    result = DocumentExportPresenter.new(publication.document).as_json
    images = result[:editions].first[:associations][:images]

    assert_equal image.image_data.file_url, images.first['url']
  end
end
