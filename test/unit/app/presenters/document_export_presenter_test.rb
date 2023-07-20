require "test_helper"

class DocumentExportPresenterTest < ActiveSupport::TestCase
  test "includes basic document and edition information" do
    document = create(:document)
    edition = create(:edition, document:)
    result = DocumentExportPresenter.new(document).as_json

    assert_equal document.content_id, result[:content_id]
    assert_equal document.slug, result[:slug]
    assert_equal edition.id, result.dig(:editions, 0, :id)
  end

  test "includes a collection of users involved with the document" do
    creator = create(:user)
    AuditTrail.whodunnit = creator
    edition = create(:publication)
    author = edition.authors.first
    remarker = create(:user)
    create(:editorial_remark, author: remarker, edition:)
    requestor = create(:user)
    create(:fact_check_request, requestor:, edition:)

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = [
      { id: creator.id,
        uid: creator.uid,
        name: creator.name,
        email: creator.email,
        organisation_slug: creator.organisation_slug,
        organisation_content_id: creator.organisation_content_id },
      { id: author.id,
        uid: author.uid,
        name: author.name,
        email: author.email,
        organisation_slug: author.organisation_slug,
        organisation_content_id: author.organisation_content_id },
      { id: remarker.id,
        uid: remarker.uid,
        name: remarker.name,
        email: remarker.email,
        organisation_slug: remarker.organisation_slug,
        organisation_content_id: remarker.organisation_content_id },
      { id: requestor.id,
        uid: requestor.uid,
        name: requestor.name,
        email: requestor.email,
        organisation_slug: requestor.organisation_slug,
        organisation_content_id: requestor.organisation_content_id },
    ]
    assert_equal expected, result[:users]
  end

  test "removes edition fields that are duplicated by the primary translation" do
    news_result = DocumentExportPresenter.new(create(:news_article).document).as_json
    edition = news_result[:editions].first
    translation = edition[:translations].first

    assert_equal "en", edition[:primary_locale]
    assert_equal "en", translation[:locale]
    assert_nil edition[:title]
    assert_nil edition[:summary]
    assert_nil edition[:body]
    assert_equal "news-title", translation[:title]
    assert_equal "news-summary", translation[:summary]
    assert_equal "news-body", translation[:body]
  end

  test "resolves internal Whitehall URLs in edition body with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    document = create(:document)
    create(:edition, document:, body:)

    linked_document = create(:document, slug: "some-article")
    linked_edition = create(:published_edition, document: linked_document, state: "published")

    Whitehall::AdminLinkLookup.stubs(:find_edition).with("/government/admin/news/2").returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "https://www.test.gov.uk/government/generic-editions/some-article",
      content_id: linked_edition.content_id,
    }]

    result = DocumentExportPresenter.new(document).as_json
    assert_equal expected_whitehall_admin_links,
                 result.dig(:editions, 0, :whitehall_admin_links)
  end

  test "resolves internal Whitehall URLs in withdrawal explanation with a public URL" do
    body = "Some text which contains an [internal link](/government/admin/news/2) to a public document"
    edition = create(:withdrawn_edition)
    edition.unpublishing.update!(explanation: body)

    linked_document = create(:document, slug: "some-article")
    linked_edition = create(:published_edition, document: linked_document, state: "published")

    Whitehall::AdminLinkLookup.stubs(:find_edition).with("/government/admin/news/2").returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "https://www.test.gov.uk/government/generic-editions/some-article",
      content_id: linked_edition.content_id,
    }]

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal expected_whitehall_admin_links,
                 result.dig(:editions, 0, :whitehall_admin_links)
  end

  test "appends the image url to the images response hash" do
    image = create(:image)
    publication = create(:publication, images: [image])

    result = DocumentExportPresenter.new(publication.document).as_json

    assert_equal image.image_data.file_url,
                 result.dig(:editions, 0, :images, 0, :url)
  end

  test "appends the image variants' urls to the images response hash" do
    image = create(:image)
    publication = create(:publication, images: [image])

    image_url_parts = image.image_data.file_url.split("/")
    filename = image_url_parts.pop
    image_dir_url = image_url_parts.join("/")
    expected = {
      s960: "#{image_dir_url}/s960_#{filename}",
      s712: "#{image_dir_url}/s712_#{filename}",
      s630: "#{image_dir_url}/s630_#{filename}",
      s465: "#{image_dir_url}/s465_#{filename}",
      s300: "#{image_dir_url}/s300_#{filename}",
      s216: "#{image_dir_url}/s216_#{filename}",
    }

    result = DocumentExportPresenter.new(publication.document).as_json
    assert_equal expected, result.dig(:editions, 0, :images, 0, :variants)
  end

  test "strips whitespace from image caption and alt_text" do
    image = create(:image, alt_text: "Alternative text ", caption: "Caption text ")
    publication = create(:publication, images: [image])

    result = DocumentExportPresenter.new(publication.document).as_json

    assert_equal "Alternative text", result.dig(:editions, 0, :images, 0, :alt_text)
    assert_equal "Caption text", result.dig(:editions, 0, :images, 0, :caption)
  end

  test "ignores variants when they do not exist" do
    svg_image_data = create(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")))
    publication = create(:publication, images: [create(:image, image_data: svg_image_data)])
    expected = {}

    result = DocumentExportPresenter.new(publication.document).as_json
    assert_equal expected, result.dig(:editions, 0, :images, 0, :variants)
  end

  test "appends expected attachment data to the file attachment response hash" do
    publication_file = create(:publication, :with_command_paper)

    result = DocumentExportPresenter.new(publication_file.document).as_json
    attachment = result.dig(:editions, 0, :attachments, 0)

    assert_equal publication_file.attachments.first.url, attachment[:url]
    assert_match(/^file-attachment-title-[0-9]+$/, attachment[:title])
    assert_equal "FileAttachment", attachment[:type]
    assert_equal publication_file.attachments.first.attachment_data.as_json.symbolize_keys,
                 attachment[:attachment_data]
  end

  test "appends the attachment variants to the file attachment response hash" do
    publication_file = create(:publication, :with_command_paper)
    result = DocumentExportPresenter.new(publication_file.document).as_json
    attachment = result.dig(:editions, 0, :attachments, 0)

    attachment_url_parts = attachment[:url].split("/")
    filename = attachment_url_parts.pop
    attachment_dir_url = attachment_url_parts.join("/")
    expected = {
      thumbnail: {
        content_type: "image/png",
        url: "#{attachment_dir_url}/thumbnail_#{filename}.png",
      },
    }
    assert_equal expected, attachment[:variants]
  end

  test "exports expected data with the external attachment response hash" do
    publication_external = create(:publication, :with_external_attachment)

    result = DocumentExportPresenter.new(publication_external.document).as_json
    attachment = result.dig(:editions, 0, :attachments, 0)

    assert_equal publication_external.attachments.first.url, attachment[:url]
    assert_equal "ExternalAttachment", attachment[:type]
  end

  test "appends expected govspeak data to the html attachment response hash" do
    publication_html = create(:publication)

    result = DocumentExportPresenter.new(publication_html.document).as_json
    attachment = result.dig(:editions, 0, :attachments, 0)

    assert_equal "HtmlAttachment", attachment[:type]
    assert_equal publication_html.attachments.first.govspeak_content.as_json.symbolize_keys,
                 attachment[:govspeak_content]
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
    assert_equal current_government.slug, result.dig(:editions, 0, :government, :slug)
  end

  test "returns alternative_format_provider content_id" do
    organisation = create(:organisation)
    edition = create(:news_article, alternative_format_provider_id: organisation.id)

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal organisation.content_id,
                 result.dig(:editions, 0, :alternative_format_provider_content_id)
  end

  test "includes authors" do
    edition = create(:edition)
    author = edition.authors.first

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal [author.id], result.dig(:editions, 0, :authors)
  end

  test "includes contacts" do
    contact = create(:contact)
    edition = create(:edition, body: "[Contact:#{contact.id}]")

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal [{ id: contact.id, content_id: contact.content_id }], result.dig(:editions, 0, :contacts)
  end

  test "includes editorial remarks" do
    author = create(:user)
    remark = create(:editorial_remark, body: "My remark", author:)

    result = DocumentExportPresenter.new(remark.edition.document).as_json
    expected = { id: remark.id,
                 body: "My remark",
                 author_id: author.id,
                 created_at: Time.zone.now }
    assert_equal expected, result.dig(:editions, 0, :editorial_remarks, 0)
  end

  test "returns fact check request details" do
    fact_check_request = create(:fact_check_request)
    edition = fact_check_request.edition

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = fact_check_request.as_json.symbolize_keys
    assert_equal expected, result.dig(:editions, 0, :fact_check_requests, 0)
  end

  test "includes history information" do
    user1 = create(:user)
    AuditTrail.whodunnit = user1
    edition = create(:edition)

    user2 = create(:user)
    AuditTrail.whodunnit = user2
    edition.update!(change_note: "changed")

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = [
      { event: "create",
        whodunnit: user1.id,
        created_at: Time.zone.now,
        state: "draft" },
      { event: "update",
        whodunnit: user2.id,
        created_at: Time.zone.now,
        state: "draft" },
    ]
    assert_equal expected, result.dig(:editions, 0, :revision_history)
  end

  test "includes organisations details" do
    organisation = create(:organisation)
    edition = create(:news_article, lead_organisations: [organisation])

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: organisation.id,
                 content_id: organisation.content_id,
                 lead: true,
                 lead_ordering: 1 }
    assert_equal expected, result.dig(:editions, 0, :organisations, 0)
  end

  test "includes role appointment (singular) details" do
    edition = create(:speech)
    role_appointment = edition.role_appointment

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: role_appointment.id,
                 content_id: role_appointment.content_id }
    assert_equal expected, result.dig(:editions, 0, :role_appointments, 0)
  end

  test "returns role appointments (plural) details" do
    role_appointment = create(:role_appointment)
    edition = create(:news_article, role_appointments: [role_appointment])

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: role_appointment.id,
                 content_id: role_appointment.content_id }
    assert_equal expected, result.dig(:editions, 0, :role_appointments, 0)
  end

  test "includes specialist sector details" do
    edition = create(:edition)
    ss = create(:specialist_sector, edition: Edition.last)

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: ss.id, topic_content_id: ss.topic_content_id, primary: ss.primary }
    assert_equal expected, result.dig(:editions, 0, :specialist_sectors, 0)
  end

  test "includes topical events details" do
    edition = create(:news_article)
    edition.topical_events.create!(name: "Super important event", description: "Not that important", summary: "Not important")
    topical_event = edition.topical_events.last

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: topical_event.id, content_id: topical_event.content_id }
    assert_equal expected, result.dig(:editions, 0, :topical_events, 0)
  end

  test "includes translations" do
    edition = create(
      :news_article,
      title: "Hello",
      summary: "Are you well?",
      body: "I am well, thank you",
    )

    english_translation = edition.translations.first
    french_translation = edition.translations
                                .create!(locale: "fr",
                                         title: "Bonjour",
                                         summary: "Ça va",
                                         body: "ça va bien merci")

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = [
      { id: english_translation.id,
        locale: "en",
        title: "Hello",
        summary: "Are you well?",
        body: "I am well, thank you",
        created_at: "2011-11-11T11:11:11.000+00:00",
        updated_at: "2011-11-11T11:11:11.000+00:00",
        base_path: "/government/news/hello" },
      { id: french_translation.id,
        locale: "fr",
        title: "Bonjour",
        summary: "Ça va",
        body: "ça va bien merci",
        created_at: "2011-11-11T11:11:11.000+00:00",
        updated_at: "2011-11-11T11:11:11.000+00:00",
        base_path: "/government/news/hello.fr" },
    ]
    assert_equal expected, result.dig(:editions, 0, :translations)
  end

  test "includes unpublishing details for withdrawn documents" do
    edition = create(:withdrawn_edition)
    result = DocumentExportPresenter.new(edition.document).as_json

    expected = {
      id: edition.unpublishing.id,
      explanation: edition.unpublishing.explanation,
      alternative_path: nil,
      created_at: edition.unpublishing.created_at,
      updated_at: edition.unpublishing.updated_at,
      redirect: false,
      unpublishing_reason: edition.unpublishing.unpublishing_reason.name,
    }

    assert_equal expected, result.dig(:editions, 0, :unpublishing)
  end

  test "includes unpublishing details for unpublished documents" do
    edition = create(:edition)
    create(:published_in_error_redirect_unpublishing, edition:)
    result = DocumentExportPresenter.new(edition.document).as_json

    expected = {
      id: edition.unpublishing.id,
      explanation: edition.unpublishing.explanation,
      alternative_path: edition.unpublishing.alternative_path,
      created_at: edition.unpublishing.created_at,
      updated_at: edition.unpublishing.updated_at,
      redirect: true,
      unpublishing_reason: edition.unpublishing.unpublishing_reason.name,
    }

    assert_equal expected, result.dig(:editions, 0, :unpublishing)
  end

  test "includes world locations details" do
    edition = create(:news_article_world_news_story)
    world_location = edition.world_locations.last

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: world_location.id, content_id: world_location.content_id }
    assert_equal expected, result.dig(:editions, 0, :world_locations, 0)
  end

  test "includes worldwide organisation (singular) details" do
    worldwide_organisation = create(:worldwide_organisation)
    edition = create(
      :corporate_information_page,
      organisation: nil,
      worldwide_organisation:,
    )

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: worldwide_organisation.id,
                 content_id: worldwide_organisation.content_id }
    assert_equal expected, result.dig(:editions, 0, :worldwide_organisations, 0)
  end

  test "includes worldwide organisations (plural) details" do
    worldwide_organisation = create(:worldwide_organisation)
    edition = create(
      :case_study,
      worldwide_organisations: [worldwide_organisation],
    )

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: worldwide_organisation.id,
                 content_id: worldwide_organisation.content_id }
    assert_equal expected, result.dig(:editions, 0, :worldwide_organisations, 0)
  end

  test "appends the editions document sub type key to the response" do
    news = create(:news_article_press_release)
    news_result = DocumentExportPresenter.new(news.document).as_json
    assert_equal "press_release", news_result.dig(:editions, 0, :news_article_type)

    publication = create(:publication, :statistics)
    publication_result = DocumentExportPresenter.new(publication.document).as_json
    assert_equal "official_statistics",
                 publication_result.dig(:editions, 0, :publication_type)

    speech = create(:speech, speech_type: SpeechType::Transcript)
    speech_result = DocumentExportPresenter.new(speech.document).as_json
    assert_equal "transcript", speech_result.dig(:editions, 0, :speech_type)

    corporate_information_page = create(:corporate_information_page)
    cip_result = DocumentExportPresenter.new(corporate_information_page.document).as_json
    assert_equal "corporate_information_page",
                 cip_result.dig(:editions, 0, :corporate_information_page_type)
  end

  test "it removes document sub type ids" do
    edition = create(:edition)
    result = DocumentExportPresenter.new(edition.document).as_json

    assert_equal edition.id, result.dig(:editions, 0, :id)
    assert_nil result.dig(:edition, 0, :news_article_type_id)
    assert_nil result.dig(:edition, 0, :publication_type_id)
    assert_nil result.dig(:edition, 0, :speech_type_id)
    assert_nil result.dig(:edition, 0, :corporate_information_page_type_id)
  end
end
