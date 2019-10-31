require "test_helper"

class DocumentExportPresenterTest < ActiveSupport::TestCase
  test "includes basic document and edition information" do
    document = create(:document)
    edition = create(:edition, document: document)
    result = DocumentExportPresenter.new(document).as_json

    assert_equal document.content_id, result[:content_id]
    assert_equal document.slug, result[:slug]
    assert_equal edition.id, result.dig(:editions, 0, :id)
  end

  test "removes edition fields that are duplicated by the primary translation" do
    news_result = DocumentExportPresenter.new(create(:news_article).document).as_json
    edition = news_result[:editions].first
    translation = edition[:translations].first

    assert_equal "en", edition[:primary_locale]
    assert_equal :en, translation[:locale]
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
    create(:edition, document: document, body: body)

    linked_document = create(:document, slug: "some-article")
    linked_edition = create(:published_edition, document: linked_document, state: "published")

    Whitehall::AdminLinkLookup.stubs(:find_edition).with("/government/admin/news/2").returns(linked_edition)

    expected_whitehall_admin_links = [{
      whitehall_admin_url: "/government/admin/news/2",
      public_url: "www.test.gov.uk/government/generic-editions/some-article",
      content_id: linked_edition.content_id,
    }]

    result = DocumentExportPresenter.new(document).as_json
    assert_equal expected_whitehall_admin_links,
                 result.dig(:editions, 0, :whitehall_admin_links)
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

  test "appends expected attachment data to the file attachment response hash" do
    publication_file = create(:publication, :with_command_paper)

    result = DocumentExportPresenter.new(publication_file.document).as_json
    attachment = result.dig(:editions, 0, :attachments, 0)

    assert_equal publication_file.attachments.first.url, attachment[:url]
    assert_equal "FileAttachment", attachment[:type]
    assert_equal publication_file.attachments.first.attachment_data.as_json.symbolize_keys,
                 attachment[:attachment_data]
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
    assert_equal ({ id: author.id, uid: author.uid }),
                 result.dig(:editions, 0, :authors, 0)
  end

  test "includes contacts" do
    contact = create(:contact)
    edition = create(:edition, depended_upon_contacts: [contact])

    result = DocumentExportPresenter.new(edition.document).as_json
    assert_equal [{ id: contact.id, content_id: contact.content_id }], result.dig(:editions, 0, :contacts)
  end

  test "includes edition policies" do
    edition = create(:news_article)
    EditionPolicy.create!(policy_content_id: SecureRandom.uuid, edition_id: edition.id)
    edition_policy = edition.edition_policies.first

    result = DocumentExportPresenter.new(edition.document).as_json
    edition_policy = { id: edition_policy.id, policy_content_id: edition_policy.policy_content_id }
    assert_equal edition_policy, result.dig(:editions, 0, :edition_policies, 0)
  end

  test "includes editorial remarks" do
    author = create(:user)
    remark = create(:editorial_remark, body: "My remark", author: author)

    result = DocumentExportPresenter.new(remark.edition.document).as_json
    expected = { id: remark.id,
                 body: "My remark",
                 author_id: author.id,
                 created_at: Time.zone.now,
                 author: { id: author.id, uid: author.uid } }
    assert_equal expected, result.dig(:editions, 0, :editorial_remarks, 0)
  end

  test "returns fact check request details" do
    fact_check_request = create(:fact_check_request)
    requestor = fact_check_request.requestor
    edition = fact_check_request.edition

    result = DocumentExportPresenter.new(edition.document).as_json
    expected_fact_check_request =
      fact_check_request.as_json(except: "requestor_id")
                        .merge(requestor: { id: requestor.id, uid: requestor.uid })
    assert_equal expected_fact_check_request.deep_symbolize_keys,
                 result.dig(:editions, 0, :fact_check_requests, 0)
  end

  test "includes history information" do
    user_1 = create(:user)
    Edition::AuditTrail.whodunnit = user_1
    edition = create(:edition)

    user_2 = create(:user)
    Edition::AuditTrail.whodunnit = user_2
    edition.update!(change_note: "changed")

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = [
      { event: "create",
        whodunnit: user_1.id.to_s,
        created_at: Time.zone.now,
        state: "draft",
        user: { id: user_1.id, uid: user_1.uid } },
      { event: "update",
        whodunnit: user_2.id.to_s,
        created_at: Time.zone.now,
        state: "draft",
        user: { id: user_2.id, uid: user_2.uid } },
    ]
    assert_equal expected, result.dig(:editions, 0, :revision_history)
  end

  test "includes last_author" do
    edition = create(:edition)
    user = create(:user)
    edition.versions.last.update!(whodunnit: user.id)

    result = DocumentExportPresenter.new(edition.document).as_json
    last_author = { id: edition.last_author.id, uid: edition.last_author.uid }
    assert_equal last_author, result.dig(:editions, 0, :last_author)
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
    edition.topical_events.create!(name: "Super important event", description: "Not that important")
    topical_event = edition.topical_events.last

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: topical_event.id, content_id: topical_event.content_id }
    assert_equal expected, result.dig(:editions, 0, :topical_events, 0)
  end

  test "includes translations" do
    edition = create(:news_article,
                     title: "Hello",
                     summary: "Are you well?",
                     body: "I am well, thank you")

    english_translation = edition.translations.first
    french_translation = edition.translations
                                .create!(locale: "fr",
                                         title: "Bonjour",
                                         summary: "Ça va",
                                         body: "ça va bien merci")

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = [
      { id: english_translation.id,
        locale: :en,
        title: "Hello",
        summary: "Are you well?",
        body: "I am well, thank you",
        created_at: english_translation.created_at,
        updated_at: english_translation.updated_at,
        base_path: "/government/news/hello" },
      { id: french_translation.id,
        locale: :fr,
        title: "Bonjour",
        summary: "Ça va",
        body: "ça va bien merci",
        created_at: french_translation.created_at,
        updated_at: french_translation.updated_at,
        base_path: "/government/news/hello.fr" },
    ]
    assert_equal expected, result.dig(:editions, 0, :translations)
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
    edition = create(:corporate_information_page,
                     organisation: nil,
                     worldwide_organisation: worldwide_organisation)

    result = DocumentExportPresenter.new(edition.document).as_json
    expected = { id: worldwide_organisation.id,
                 content_id: worldwide_organisation.content_id }
    assert_equal expected, result.dig(:editions, 0, :worldwide_organisations, 0)
  end

  test "includes worldwide organisations (plural) details" do
    worldwide_organisation = create(:worldwide_organisation)
    edition = create(:case_study,
                     worldwide_organisations: [worldwide_organisation])

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
