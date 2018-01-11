require 'test_helper'

class PublishingApi::DocumentCollectionPresenterTest < ActiveSupport::TestCase
  setup do
    create(:current_government)

    @document_collection = create(
      :document_collection,
      title: "Document Collection title",
      summary: "Document Collection summary"
    )

    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
    @presented_content = I18n.with_locale("de") { @presented_document_collection.content }
  end

  test "it presents a valid document_collection content item" do
    assert_valid_against_schema @presented_content, "document_collection"
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

  test "it presents the base_path" do
    assert_equal "/government/collections/document-collection-title", @presented_content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    assert_equal @document_collection.updated_at, @presented_content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal 'whitehall', @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as government-frontend" do
    assert_equal 'government-frontend', @presented_content[:rendering_app]
  end

  test "it presents the schema_name as document_collection" do
    assert_equal "document_collection", @presented_content[:schema_name]
  end

  test "it presents the document type as document_collection" do
    assert_equal "document_collection", @presented_content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the document_collection" do
    assert_equal "de", @presented_content[:locale]
  end
end

class PublishingApi::DocumentCollectionPresenterWithPublicTimestampTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.zone.parse("10/01/2016")
    @document_collection = create(
      :document_collection
    )
    @document_collection.public_timestamp = @expected_time
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
  end

  test "it presents public_timestamp if it exists" do
    assert_equal @expected_time, @presented_document_collection.content[:public_updated_at]
  end
end

class PublishingApi::DraftDocumentCollectionPresenter < ActiveSupport::TestCase
  test "it presents the Document Collection's parent document created_at as first_public_at" do
    presented_notice = PublishingApi::DocumentCollectionPresenter.new(
      create(:draft_document_collection) do |document_collection|
        document_collection.document.stubs(:created_at).returns(Date.new(2015, 4, 10))
      end
    )

    assert_equal(
      Date.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at]
    )
  end
end

class PublishingApi::DraftDocumentCollectionBelongingToPublishedDocumentNoticePresenter < ActiveSupport::TestCase
  test "it presents the Document Collection's first_published_at as first_public_at" do
    presented_notice = PublishingApi::DocumentCollectionPresenter.new(
      create(:published_document_collection) do |document_collection|
        document_collection.stubs(:first_published_at).returns(Date.new(2015, 4, 10))
      end
    )

    assert_equal(
      Date.new(2015, 04, 10),
      presented_notice.content[:details][:first_public_at]
    )
  end
end

class PublishingApi::DocumentCollectionPresenterGroupTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection, :with_groups)
    group_one = document_collection.groups.first
    group_two = document_collection.groups.second

    group_one.stubs(:documents).returns(
      [
        stub(content_id: "aaa"),
        stub(content_id: "bbb"),
      ]
    )
    group_two.stubs(:documents).returns(
      [
        stub(content_id: "fff"),
        stub(content_id: "eee"),
      ]
    )
    group_one.stubs(:heading).returns(
      "Group 1"
    )
    group_two.stubs(:heading).returns(
      "Group 2"
    )

    presenter = PublishingApi::DocumentCollectionPresenter.new(
      document_collection
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
          "documents": %w(aaa bbb)
        },
        {
          "title": "Group 2",
          "body": "<div class=\"govspeak\"><p>Group body text</p>\n</div>",
          "documents": %w(fff eee)
        }
      ],
      @presented_details[:collection_groups]
    )
  end
end

class PublishingApi::DocumentCollectionPresenterDocumentLinksTestCase < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection)
    documents = mock('documents')
    documents.expects(:pluck).with(:content_id).returns(%w(faf afa))
    document_collection.stubs(:documents).returns(documents)

    @presented_links = PublishingApi::DocumentCollectionPresenter.new(
      document_collection
    ).content[:links]
  end

  test "it presents the document content_ids as links, documents" do
    assert_equal(
      %w(faf afa),
      @presented_links[:documents]
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_first_published_at = Time.new(2015, 12, 25)
    @document_collection = create(
      :document_collection,
      :published,
      body: "*Test string*",
      first_published_at: @expected_first_published_at
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
        "note" => "change-note"
      }
    ]

    assert_equal change_history, @presented_details[:change_history]
  end

  test "it presents the lead organisation content_ids as details, emphasised_organisations" do
    assert_equal(
      @document_collection.lead_organisations.map(&:content_id),
      @presented_details[:emphasised_organisations]
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
      @presented_links[:organisations]
    )
  end

  test "it presents the policy area content_ids as links, policy_areas" do
    assert_equal(
      @document_collection.topics.map(&:content_id),
      @presented_links[:policy_areas]
    )
  end

  test "it presents the topic content_ids as links, topics" do
    assert_equal(
      @document_collection.specialist_sectors.map(&:content_id),
      @presented_links[:topics]
    )
  end

  test "it presents the primary_specialist_sector content_id as links, parent" do
    assert_equal(
      @document_collection.primary_specialist_sectors.map(&:content_id),
      @presented_links[:parent]
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
      @document_collection.documents.map(&:content_id),
      @presented_links[:documents]
    )
  end

  test "it presents the organisation content_ids as links, organisations" do
    assert_equal(
      @document_collection.organisations.map(&:content_id),
      @presented_links[:organisations]
    )
  end

  test "it presents the policy area content_ids as links, policy_areas" do
    assert_equal(
      @document_collection.topics.map(&:content_id),
      @presented_links[:policy_areas]
    )
  end

  test "it presents the topic content_ids as links, topics" do
    assert_equal(
      @document_collection.specialist_sectors.map(&:content_id),
      @presented_links[:topics]
    )
  end

  test "it presents the topical_events content_ids as links, topical_events" do
    assert_equal(
      @document_collection.topical_events.map(&:content_id),
      @presented_links[:topical_events]
    )
  end

  test "it presentes the primary_specialist_sector content_ids as links, parent" do
    assert_equal(
      @document_collection.primary_specialist_sectors.map(&:content_id),
      @presented_links[:parent]
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterDuplicateDocumentsTest < ActiveSupport::TestCase
  setup do
    @document_collection = create(:document_collection)
    documents = mock('documents')
    documents.expects(:pluck).twice.with(:content_id).returns(%w(test test ers))
    @document_collection.stubs(:documents).returns(documents)
    presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
    @presented_edition_links = presented_document_collection.content[:links]
    @presented_links = presented_document_collection.links
  end

  test "it doesn't present duplicate content ids in content, links, documents" do
    assert_equal(
      %w(test ers),
      @presented_edition_links[:documents]
    )
  end

  test "it doesn't present duplicate content ids in links, documents" do
    assert_equal(
      %w(test ers),
      @presented_links[:documents]
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterRelatedPolicyLinksTest < ActiveSupport::TestCase
  setup do
    @document_collection = create(:document_collection)
    @document_collection.stubs(:policy_content_ids).returns([
      "5a8420a2-eafa-4780-87f4-9cf5fb6783f3",
      "a8b90171-7f0a-4dd5-986c-d9e414a2dc17",
      "7a892570-6428-4baa-b825-9ebc4faf5773"
    ])
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(@document_collection)
  end

  test "it presents the policy_content_ids as links, related_policies" do
    assert_equal(
      @document_collection.policy_content_ids,
      @presented_document_collection.links[:related_policies]
    )
  end

  test "it presents the policy_content_ids as content, links, related_policies" do
    assert_equal(
      @document_collection.policy_content_ids,
      @presented_document_collection.content[:links][:related_policies]
    )
  end
end

class PublishingApi::PublishedDocumentCollectionPresenterTopicalEventsLinksTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection)
    PublishingApi::PayloadBuilder::TopicalEvents.stubs(:for).with(document_collection).returns(topical_events: ['bfa'])
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(document_collection)
  end

  test "it presents the topical events as links, topical_events" do
    assert_equal(
      ["bfa"],
      @presented_document_collection.links[:topical_events]
    )
  end

  test "it presents the topical events as content, links, topical_events" do
    assert_equal(
      ["bfa"],
      @presented_document_collection.content[:links][:topical_events]
    )
  end
end

class PublishingApi::DocumentCollectionPresenterUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection, minor_change: false)
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "major", @presented_document_collection.update_type
  end
end

class PublishingApi::DocumentCollectionPresenterMinorUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection, minor_change: true)
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
      update_type: "major"
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
    create(
      :current_government,
      name: "The Current Government",
      slug: "the-current-government",
    )
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(:document_collection)
    )
  end

  test "presents a current government" do
    assert_equal(
      {
        "title": "The Current Government",
        "slug": "the-current-government",
        "current": true
      },
      @presented_document_collection.content[:details][:government]
    )
  end
end

class PublishingApi::DocumentCollectionPresenterPreviousGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    create(:current_government)
    previous_government = create(
      :previous_government,
      name: "A Previous Government",
      slug: "a-previous-government",
    )
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      create(
        :document_collection,
        first_published_at: previous_government.start_date + 1.day
      )
    )
  end

  test "presents a previous government" do
    assert_equal(
      {
        "title": "A Previous Government",
        "slug": "a-previous-government",
        "current": false
      },
      @presented_document_collection.content[:details][:government]
    )
  end
end

class PublishingApi::DocumentCollectionPresenterPoliticalTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection)
    document_collection.stubs(:political?).returns(true)
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      document_collection
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
        access_limited: { users: %w(abcdef12345) }
      )
    @presented_document_collection = PublishingApi::DocumentCollectionPresenter.new(
      document_collection
    )
  end

  test "include access limiting" do
    assert_equal %w(abcdef12345), @presented_document_collection.content[:access_limited][:users]
  end

  test "is valid against content schemas" do
    assert_valid_against_schema @presented_document_collection.content, "document_collection"
  end
end
