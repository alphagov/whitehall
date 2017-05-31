require 'test_helper'

class PublishingApi::PublicationPresenterTest < ActiveSupport::TestCase
  def present(edition)
    PublishingApi::PublicationPresenter.new(edition)
  end

  test "publication presentation includes the correct values" do
    government = create(:government)
    statistical_data_set = create(:published_statistical_data_set)
    publication = create(:published_publication,
                    title: 'Publication title',
                    summary: 'The summary',
                    body: 'Some content',
                    statistical_data_sets: [statistical_data_set])

    public_path = Whitehall.url_maker.public_document_path(publication)
    expected_content = {
      base_path: public_path,
      title: 'Publication title',
      description: 'The summary',
      schema_name: 'publication',
      document_type: 'policy_paper',
      locale: 'en',
      need_ids: [],
      public_updated_at: publication.public_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      first_published_at: publication.first_public_at,
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        tags: {
          browse_pages: [],
          policies: ['2012-olympic-and-paralympic-legacy'],
          topics: []
        },
        documents: ["<section class=\"attachment embedded\" id=\"attachment_1\">\n  <div class=\"attachment-thumb\">\n      <a aria-hidden=\"true\" class=\"thumbnail\" href=\"/government/publications/publication-title/#{publication.attachments.first.title}\"><img alt=\"\" src=\"/government/assets/pub-cover-html.png\" /></a>\n  </div>\n  <div class=\"attachment-details\">\n    <h2 class=\"title\"><a href=\"/government/publications/publication-title/#{publication.attachments.first.title}\">#{publication.attachments.first.title}</a></h2>\n    <p class=\"metadata\">\n        <span class=\"type\">HTML</span>\n    </p>\n\n\n  </div>\n</section>"],
        first_public_at: publication.first_public_at,
        change_history: [
          { public_timestamp: publication.public_timestamp, note: 'change-note' }.as_json
        ],
        emphasised_organisations: publication.lead_organisations.map(&:content_id),
        political: false,
        government: {
          title: government.name,
          slug: government.slug,
          current: government.current?
        },
      },
    }

    minister = create(:ministerial_role_appointment)
    publication.role_appointments << minister
    topical_event = create(:topical_event)
    publication.classification_memberships.create(classification_id: topical_event.id)
    publication.policy_content_ids = ['5d37821b-7631-11e4-a3cb-005056011aef']

    expected_links = {
      topics: [],
      parent: [],
      organisations: publication.lead_organisations.map(&:content_id),
      ministers: [minister.person.content_id],
      related_statistical_data_sets: [statistical_data_set.content_id],
      world_locations: [],
      topical_events: [topical_event.content_id],
      related_policies: ['5d37821b-7631-11e4-a3cb-005056011aef'],
      policy_areas: publication.topics.map(&:content_id),
      roles: publication.role_appointments.map(&:role).collect(&:content_id),
      people: publication.role_appointments.map(&:person).collect(&:content_id)
    }
    expected_content.merge!(links: expected_links)

    presented_item = present(publication)

    assert_valid_against_schema(presented_item.content, 'publication')
    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')

    assert_equal expected_content.except(:details),
      presented_item.content.except(:details)

    # We test for HTML equivlance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_content[:details].delete(:body),
      presented_item.content[:details].delete(:body)
    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_hash_includes presented_item.links, expected_links
    assert_equal expected_links, presented_item.content[:links]
    assert_equal publication.document.content_id, presented_item.content_id
  end

  test 'links hash includes topics and parent if set' do
    edition = create(:published_publication)
    create(:specialist_sector, topic_content_id: "content_id_1", edition: edition, primary: true)
    create(:specialist_sector, topic_content_id: "content_id_2", edition: edition, primary: false)

    presented = present(edition)
    links = presented.links
    edition_links = presented.content[:links]

    assert_equal links[:topics], %w(content_id_1 content_id_2)
    assert_equal links[:parent], %w(content_id_1)

    assert_equal edition_links[:topics], %w(content_id_1 content_id_2)
    assert_equal edition_links[:parent], %w(content_id_1)
  end

  test "links hash includes lead and supporting organisations in correct order" do
    lead_org_1 = create(:organisation)
    lead_org_2 = create(:organisation)
    supporting_org = create(:organisation)
    publication = create(:published_publication,
                        lead_organisations: [lead_org_1, lead_org_2],
                        supporting_organisations: [supporting_org])
    presented_item = present(publication)
    expected_links_hash = {
      topics: [],
      parent: [],
      organisations: [lead_org_1.content_id, lead_org_2.content_id, supporting_org.content_id],
      world_locations: [],
      ministers: [],
      related_statistical_data_sets: [],
      topical_events: [],
      policy_areas: publication.topics.map(&:content_id),
      related_policies: []
    }

    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')
    assert_equal expected_links_hash, presented_item.links
    assert_equal expected_links_hash, presented_item.content[:links]
  end

  test "details hash includes full document history" do
    original_timestamp = 2.days.ago
    original = create(:superseded_publication, first_published_at: original_timestamp)
    new_timestamp = Time.zone.now
    create(:government)
    new_edition = create(:published_publication, document: original.document, published_major_version: 2, change_note: "More changes", major_change_published_at: new_timestamp)
    presented_item = present(new_edition)
    assert_valid_against_schema(presented_item.content, 'publication')
    presented_history = presented_item.content[:details][:change_history]
    expected_history = [
      { public_timestamp: new_timestamp, note: "More changes" },
      { public_timestamp: original_timestamp, note: "change-note" }
    ].as_json
    assert_equal expected_history, presented_history
  end

  test "links hash includes world locations" do
    location = create(:world_location)
    publication = create(:published_publication,
                        world_locations: [location])
    presented_item = present(publication)
    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')
    assert_equal [location.content_id], presented_item.links[:world_locations]
    assert_equal [location.content_id], presented_item.content[:links][:world_locations]
  end

  test "documents include the alternative format contact email" do
    publication = create(:publication, :with_command_paper)
    presented_item = present(publication)
    document = presented_item.content[:details][:documents].first
    assert document.include?("This file may not be suitable for users of assistive technology.")
    assert document.include?("mailto:#{publication.alternative_format_provider.alternative_format_contact_email}")
  end

  test "it uses the PayloadBuilder::FirstPublishedAt helper" do
    publication = create(:publication)
    PublishingApi::PayloadBuilder::FirstPublishedAt.stubs(:for).with(publication).returns({ first_published_at: 'test' })
    PublishingApi::PayloadBuilder::FirstPublicAt.stubs(:for).with(publication).returns({ first_public_at: 'test' })
    presented_publication = PublishingApi::PublicationPresenter.new(publication)
    @presented_content = presented_publication.content

    assert_equal('test', @presented_content[:first_published_at])
    assert_equal('test', @presented_content[:details][:first_public_at])
  end

  test "specific locale attachments are presented for that locale" do
    #this factory creates an nil locale attachment
    publication = create(:published_publication)
    attachment = publication.html_attachments.first
    attachment.update_attributes!(locale: 'cy', title: "welsh one")
    publication.reload #ensures the html attachment is in #attachments and #html_attachmnents

    presented_publication = PublishingApi::PublicationPresenter.new(publication)

    I18n.with_locale(:cy) do
      document_elements = presented_publication.content[:details][:documents]
      assert_equal 1, document_elements.count
      assert document_elements.first =~ /welsh one/
    end
  end

  test "specific locale attachments are not presented for other locales" do
    #this factory creates an nil locale attachment
    publication = create(:published_publication)
    attachment = publication.html_attachments.first
    attachment.update_attributes!(locale: 'cy', title: "welsh one")
    publication.reload

    presented_publication = PublishingApi::PublicationPresenter.new(publication)

    I18n.with_locale(:en) do
      document_elements = presented_publication.content[:details][:documents]
      assert_equal 0, document_elements.count
    end
  end

  test "nil locale attachments are present for all locales" do
    #this factory creates an nil locale attachment
    publication = create(:published_publication)
    attachment = publication.html_attachments.first
    attachment.update_attributes!(title: "nil one")
    publication.reload

    presented_publication = PublishingApi::PublicationPresenter.new(publication)

    I18n.with_locale(:cy) do
      document_elements = presented_publication.content[:details][:documents]
      assert_equal 1, document_elements.length
      assert_match(/nil one/, document_elements.first)
    end

    I18n.with_locale(:en) do
      document_elements = presented_publication.content[:details][:documents]
      assert_equal 1, document_elements.length
      assert_match(/nil one/, document_elements.first)
    end
  end

  test "file attachments are correctly filtered for locale" do
    publication = create(:published_publication)
    publication.stubs(:attachments).returns(
      [
        build(:csv_attachment, id: 1, title: "en one", locale: "en"),
        build(:csv_attachment, id: 2, title: "cy one", locale: "cy"),
        build(:csv_attachment, id: 3, title: "nil one", locale: nil)
      ]
    )

    presented_publication = PublishingApi::PublicationPresenter.new(publication)

    I18n.with_locale(:cy) do
      document_elements = presented_publication.content[:details][:documents]
      assert_equal 2, document_elements.length
      assert_match(/cy one/, document_elements.first)
      assert_match(/nil one/, document_elements.last)
    end

    I18n.with_locale(:en) do
      document_elements = presented_publication.content[:details][:documents]
      assert_equal 2, document_elements.length
      assert_match(/en one/, document_elements.first)
      assert_match(/nil one/, document_elements.last)
    end
  end
end
