require "test_helper"

class DocumentExportPresenterTest < ActiveSupport::TestCase
  test "resolves internal Whitehall URLs in edition body with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    document = create(:document)
    create(:edition, document: document, body: body)

    linked_document = create(:document, slug: "some-article")
    linked_edition = create(:published_edition, document: linked_document, state: "published")

    Whitehall::AdminLinkLookup.stubs(:find_edition).with("/government/admin/news/2").returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "www.test.gov.uk/government/generic-editions/some-article",
    }]

    result = DocumentExportPresenter.new(document).as_json
    assert_equal expected_whitehall_admin_links, result[:editions][0][:whitehall_admin_links]
  end

  test "resolves internal Whitehall URLs in withdrawal explanation with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    edition = create(:withdrawn_edition)
    edition.unpublishing.update_attribute(:explanation, body)

    linked_document = create(:document, slug: "some-article")
    linked_edition = create(:published_edition, document: linked_document, state: "published")

    Whitehall::AdminLinkLookup.stubs(:find_edition).with("/government/admin/news/2").returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "www.test.gov.uk/government/generic-editions/some-article",
    }]

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal expected_whitehall_admin_links, result[:editions][-1][:whitehall_admin_links]
  end

  test "appends the image url to the images response hash" do
    image = create(:image)
    publication = create(:publication, images: [image])

    result = DocumentExportPresenter.new(publication.document).as_json
    images = result[:editions].first[:associations][:images]

    assert_equal image.image_data.file_url, images.first["url"]
  end

  test "appends expected attachment data to the file attachment response hash" do
    publication_file = create(:publication, :with_command_paper)

    result = DocumentExportPresenter.new(publication_file.document).as_json
    attachments = result[:editions].first[:associations][:attachments]

    assert_equal publication_file.attachments.first.url, attachments.first["url"]
    assert_equal "FileAttachment", attachments.first["type"]
    assert_equal publication_file.attachments.first.attachment_data.as_json, attachments.first["attachment_data"]
  end

  test "exports expected data with the external attachment response hash" do
    publication_external = create(:publication, :with_external_attachment)

    result = DocumentExportPresenter.new(publication_external.document).as_json
    attachments = result[:editions].first[:associations][:attachments]

    assert_equal publication_external.attachments.first.url, attachments.first["url"]
    assert_equal "ExternalAttachment", attachments.first["type"]
  end

  test "appends expected govspeak data to the html attachment response hash" do
    publication_html = create(:publication)

    result = DocumentExportPresenter.new(publication_html.document).as_json
    attachments = result[:editions].first[:associations][:attachments]

    assert_equal "HtmlAttachment", attachments.first["type"]
    assert_equal publication_html.attachments.first.govspeak_content.as_json, attachments.first["govspeak_content"]
  end

  test "appends the editions document type key to the response" do
    news = create(:news_article)
    publication = create(:publication)
    speech = create(:speech)
    corp_info = create(:corporate_information_page)

    news_result = DocumentExportPresenter.new(news.document).as_json
    doctype_data = news_result[:editions].first[:news_article_type]
    assert_equal news.news_article_type.key, doctype_data

    pub_result = DocumentExportPresenter.new(publication.document).as_json
    doctype_data = pub_result[:editions].first[:publication_type]
    assert_equal publication.publication_type.key, doctype_data

    speech_result = DocumentExportPresenter.new(speech.document).as_json
    doctype_data = speech_result[:editions].first[:speech_type]
    assert_equal speech.speech_type.key, doctype_data

    corp_result = DocumentExportPresenter.new(corp_info.document).as_json
    doctype_data = corp_result[:editions].first[:corporate_information_page_type]
    assert_equal corp_info.corporate_information_page_type.key, doctype_data
  end

  test "returns government information about an edition" do
    current_government = create(:current_government)
    edition = create(:edition)
    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal edition.government, result[:editions].first[:government]
    assert_equal current_government, result[:editions].first[:government]
  end

  test "converts ids to descriptive fields" do
    news = create(:news_article)
    news_result = DocumentExportPresenter.new(news.document).as_json
    edition = news_result[:editions].first[:edition]

    assert_nil edition["news_article_type_id"]
    assert_equal "press_release", edition["news_article_type"]
  end
end
