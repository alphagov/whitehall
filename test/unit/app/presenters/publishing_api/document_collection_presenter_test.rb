require "test_helper"

class PublishingApi::DocumentCollectionPresenterTest < ActiveSupport::TestCase
  setup do
    create(:current_government)

    @document_collection = create(
      :document_collection,
      title: "Document Collection title",
      summary: "Document Collection summary",
    )

    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
    @presented_en_content = @presented_document_collection.content
    @presented_content = I18n.with_locale("de") { @presented_document_collection.content }
    @presented_links = I18n.with_locale("de") { @presented_document_collection.links }
  end

  test "it presents a valid document_collection content item" do
    assert_valid_against_publisher_schema @presented_content, "document_collection"
    assert_valid_against_links_schema({ links: @presented_links }, "document_collection")
  end

  test "it delegates the content id" do
    assert_equal @document_collection.content_id, @presented_document_collection.content_id
  end

  test "it presents the title" do
    assert_equal "Document Collection title", @presented_content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "Document Collection summary", @presented_content[:description]
  end

  test "it presents the base_path if locale is :en" do
    assert_equal "/government/collections/document-collection-title", @presented_en_content[:base_path]
  end

  test "it presents the base_path with locale if non-english" do
    assert_equal "/government/collections/document-collection-title.de", @presented_content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    assert_equal @document_collection.updated_at, @presented_content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal Whitehall::PublishingApp::WHITEHALL, @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as frontend" do
    assert_equal "frontend", @presented_content[:rendering_app]
  end

  test "it presents the schema_name as document_collection" do
    assert_equal "document_collection", @presented_content[:schema_name]
  end

  test "it presents the document type as document_collection" do
    assert_equal "document_collection", @presented_content[:document_type]
  end

  test "it presents the default global process wide locale as the locale of the document_collection" do
    assert_equal "en", @presented_en_content[:locale]
  end

  test "it presents the selected global process wide locale as the locale of the document_collection" do
    assert_equal "de", @presented_content[:locale]
  end

  test "it presents the auth bypass id" do
    assert_equal [@document_collection.auth_bypass_id], @presented_content[:auth_bypass_ids]
  end

  test "it includes headers when headers are present in body" do
    document_collection = create(
      :document_collection,
      title: "Some document collection",
      summary: "Some summary",
      body: "##Some header\n\nSome content",
    )

    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(document_collection)

    expected_headers = [
      {
        text: "Some header",
        level: 2,
        id: "some-header",
      },
    ]

    assert_equal expected_headers, presented_document_collection.content[:details][:headers]
  end

  test "it does not include headers when headers are not present in body" do
    document_collection = create(
      :published_document_collection,
      title: "Some document collection",
      summary: "Some summary",
      body: "Some content",
    )

    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(document_collection)

    assert_nil presented_document_collection.content[:details][:headers]
  end
end

class PublishingApi::DocumentCollectionPresenterWithPublicTimestampTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.zone.parse("10/01/2016")
    @document_collection = create(
      :document_collection,
    )
    @document_collection.public_timestamp = @expected_time
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
  end

  test "it presents public_timestamp if it exists" do
    assert_equal @expected_time, @presented_document_collection.content[:public_updated_at]
  end
end

class PublishingApi::DraftDocumentCollectionBelongingToPublishedDocumentNoticePresenter < ActiveSupport::TestCase
  test "it presents the Document Collection's first_published_at as first_public_at" do
    presented_notice = PublishingApi::DocumentCollectionPresenter.new(
      create(:published_document_collection) do |document_collection|
        document_collection.stubs(:first_published_at).returns(Date.new(2015, 4, 10))
      end,
    )

    assert_equal(
      Date.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at],
    )
  end
end

class PublishingApi::DocumentCollectionPresenterGroupTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection, :with_groups)
    group_one = document_collection.groups.first
    group_two = document_collection.groups.second

    group_one.stubs(:content_ids).returns(%w[aaa bbb])
    group_two.stubs(:content_ids).returns(%w[fff eee])
    group_one.stubs(:heading).returns("Group 1")
    group_two.stubs(:heading).returns("Group 2")

    presenter = PublishingApi::DocumentCollectionPresenter.new(
      document_collection,
    )
    @presented_details = presenter.content[:details]
    @presented_links = presenter.content[:links]
  end

  test "it presents group 1 in collection_groups" do
    assert_equal(
      [
        {
          "title": "Group 1",
          "body": "<div class=\"govspeak\"><p>Group body text</p>\n</div>",
          "documents": %w[aaa bbb],
        },
        {
          "title": "Group 2",
          "body": "<div class=\"govspeak\"><p>Group body text</p>\n</div>",
          "documents": %w[fff eee],
        },
      ],
      @presented_details[:collection_groups],
    )
  end
end

class PublishingApi::DocumentCollectionPresenterDocumentLinksTestCase < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection)
    document_collection.stubs(:content_ids).returns(%w[faf afa])

    @presented_links = PublishingApi::DocumentCollectionPresenter.new(
      document_collection,
    ).content[:links]
  end

  test "it presents the document content_ids as links, documents" do
    assert_equal(
      %w[faf afa],
      @presented_links[:documents],
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_first_published_at = Time.zone.local(2011, 2, 5)
    @document_collection = create(
      :document_collection,
      :published,
      body: "*Test string*",
      first_published_at: @expected_first_published_at,
    )

    @presented_content = PublishingApi::DocumentCollectionPresenter.new(@document_collection).content
    @presented_details = @presented_content[:details]
  end

  test "it presents first_public_at as details, first_public_at" do
    assert_equal @expected_first_published_at, @presented_details[:first_public_at]
  end

  test "it presents change_history" do
    change_history = [
      {
        "public_timestamp" => @expected_first_published_at,
        "note" => "change-note",
      },
    ]

    assert_equal change_history, @presented_details[:change_history]
  end

  test "it presents the lead organisation content_ids as details, emphasised_organisations" do
    assert_equal(
      @document_collection.lead_organisations.map(&:content_id),
      @presented_details[:emphasised_organisations],
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterLinksTest < ActiveSupport::TestCase
  setup do
    @document_collection = create(:document_collection)
    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
    @presented_links = presented_document_collection.links
  end

  test "it presents the organisation content_ids as links, organisations" do
    assert_equal(
      @document_collection.organisations.map(&:content_id),
      @presented_links[:organisations],
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterEditionLinksTest < ActiveSupport::TestCase
  setup do
    @document_collection = create(:document_collection)
    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
    @presented_links = presented_document_collection.content[:links]
  end

  test "it presents the documents content_ids as links, documents" do
    assert_equal(
      @document_collection.content_ids,
      @presented_links[:documents],
    )
  end

  test "it presents the organisation content_ids as links, organisations" do
    assert_equal(
      @document_collection.organisations.map(&:content_id),
      @presented_links[:organisations],
    )
  end

  test "it presents the topical_events content_ids as links, topical_events" do
    assert_equal(
      @document_collection.topical_events.map(&:content_id),
      @presented_links[:topical_events],
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterDuplicateDocumentsTest < ActiveSupport::TestCase
  setup do
    @document_collection = create(:document_collection)
    @document_collection.stubs(:content_ids).returns(%w[test test ers])
    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
    @presented_edition_links = presented_document_collection.content[:links]
    @presented_links = presented_document_collection.links
  end

  test "it doesn't present duplicate content ids in content, links, documents" do
    assert_equal(
      %w[test ers],
      @presented_edition_links[:documents],
    )
  end

  test "it doesn't present duplicate content ids in links, documents" do
    assert_equal(
      %w[test ers],
      @presented_links[:documents],
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterTopicalEventsLinksTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection)
    PublishingApi::PayloadBuilder::TopicalEvents.stubs(:for).with(document_collection).returns(topical_events: %w[bfa])
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(document_collection)
  end

  test "it presents the topical events as links, topical_events" do
    assert_equal(
      %w[bfa],
      @presented_document_collection.links[:topical_events],
    )
  end

  test "it presents the topical events as content, links, topical_events" do
    assert_equal(
      %w[bfa],
      @presented_document_collection.content[:links][:topical_events],
    )
  end
end

class PublishingApi::DocumentCollectionPresenterUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection, minor_change: false),
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "major", @presented_document_collection.update_type
  end
end

class PublishingApi::DocumentCollectionPresenterMinorUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection, minor_change: true),
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "minor", @presented_document_collection.update_type
  end
end

class PublishingApi::DocumentCollectionPresenterUpdateTypeArgumentTest < ActiveSupport::TestCase
  setup do
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection, minor_change: true),
      update_type: "major",
    )
  end

  test "presents based on the supplied update type argument" do
    assert_equal "major", @presented_document_collection.update_type
  end
end

class PublishingApi::DocumentCollectionPresenterCurrentGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    @current_government = create(
      :current_government,
      name: "The Current Government",
      slug: "the-current-government",
    )
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection),
    )
  end

  test "presents a current government" do
    assert_equal(
      @current_government.content_id,
      @presented_document_collection.links.dig(:government, 0),
    )
  end
end

class PublishingApi::DocumentCollectionPresenterPreviousGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    create(:current_government)
    @previous_government = create(
      :previous_government,
      name: "A Previous Government",
      slug: "a-previous-government",
    )
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(
        :document_collection,
        first_published_at: @previous_government.start_date + 1.day,
      ),
    )
  end

  test "presents a previous government" do
    assert_equal(
      @previous_government.content_id,
      @presented_document_collection.links.dig(:government, 0),
    )
  end
end

class PublishingApi::DocumentCollectionPresenterPoliticalTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection)
    document_collection.stubs(:political?).returns(true)
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      document_collection,
    )
  end

  test "presents political" do
    assert @presented_document_collection.content[:details][:political]
  end
end

class PublishingApi::DocumentCollectionAccessLimitedTest < ActiveSupport::TestCase
  setup do
    create(:current_government)
    document_collection = create(:document_collection)

    PublishingApi::PayloadBuilder::AccessLimitation.expects(:for)
      .with(document_collection)
      .returns(
        access_limited: { users: %w[abcdef12345] },
      )
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      document_collection,
    )
  end

  test "include access limiting" do
    assert_equal %w[abcdef12345], @presented_document_collection.content[:access_limited][:users]
  end

  test "is valid against content schemas" do
    assert_valid_against_publisher_schema @presented_document_collection.content, "document_collection"
    assert_valid_against_links_schema({ links: @presented_document_collection.links }, "document_collection")
  end
end

class PublishingApi::DocumentCollectionWithTaxonomyTopicEmailOverrideTest < ActiveSupport::TestCase
  setup do
    create(:current_government)
  end

  test "presents the taxonomy_topic_email_override when one exists" do
    taxonomy_topic_email_override = "9b889c60-2191-11ee-be56-0242ac120002"
    document_collection = create(:document_collection, taxonomy_topic_email_override:)
    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(document_collection)

    assert_equal [taxonomy_topic_email_override], presented_document_collection.links[:taxonomy_topic_email_override]

    assert_valid_against_publisher_schema presented_document_collection.content, "document_collection"
    assert_valid_against_links_schema({ links: presented_document_collection.links }, "document_collection")
  end

  test "does not present the taxonomy_topic_email_override if it is nil" do
    document_collection = create(:document_collection)
    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(document_collection)

    assert_not presented_document_collection.links.key?(:taxonomy_topic_email_override)

    assert_valid_against_links_schema({ links: presented_document_collection.links }, "document_collection")
  end
end
