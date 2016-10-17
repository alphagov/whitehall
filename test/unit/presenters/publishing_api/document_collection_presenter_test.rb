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
    skip
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

  test "it presents the rendering_app as whitehall-frontend" do
    assert_equal 'whitehall-frontend', @presented_content[:rendering_app]
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
      DateTime.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at]
    )
  end
end

class PublishingApi::DraftDocumentCollectionBelongingToPublishedDocumentNoticePresenter < ActiveSupport::TestCase
  test "it presents the Document Collection's first_published_at as first_public_at" do
    presented_notice = PublishingApi::DocumentCollectionPresenter.new(
      create(:published_document_collection) do |document_collection|
        document_collection.stubs(:first_published_at).returns(DateTime.new(2015, 4, 10))
      end
    )

    assert_equal(
      DateTime.new(2015, 04, 10),
      presented_notice.content[:details][:first_public_at]
    )
  end
end

class PublishingApi::DocumentCollectionPresenterGroupTest < ActiveSupport::TestCase
  setup do
    document_collection = create(:document_collection, :with_groups)
    document_collection.groups.first.stubs(:documents).returns(
      [
        stub(content_id: "aaa"),
        stub(content_id: "bbb"),
      ]
    )
    document_collection.groups.second.stubs(:documents).returns(
      [
        stub(content_id: "fff"),
        stub(content_id: "eee"),
      ]
    )

    @presented_details = PublishingApi::DocumentCollectionPresenter.new(
      document_collection
    ).content[:details]
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

class PublishingApi::PublishedDocumentCollectionPresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_first_published_at = DateTime.new(2015, 12, 25)
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

  test "it presents first_published_at at top level" do
    assert_equal @expected_time, @presented_content[:first_published_at]
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
