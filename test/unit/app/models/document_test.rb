require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include GdsApi::TestHelpers::PublishingApi

  test "should return documents that have live editions" do
    create(:superseded_publication)
    create(:draft_publication)
    published_publication = create(:published_publication)
    withdrawn_publication = create(:withdrawn_publication)

    assert_equal [published_publication.document, withdrawn_publication.document], Document.live
  end

  test "should return the live edition" do
    user = create(:departmental_editor)
    document = create(:document)
    original_publication = create(:draft_publication, document:)
    force_publish(original_publication)
    draft_publication = original_publication.create_draft(user)
    draft_publication.change_note = "change-note"
    force_publish(draft_publication)

    _superseded_publication = original_publication
    published_publication = draft_publication
    _new_draft_publication = published_publication.create_draft(user)

    assert_equal published_publication, document.reload.live_edition
  end

  test "should be able to retrieve documents of a certain type at a particular slug" do
    publication = create(:draft_publication)
    assert_equal publication.document, Document.at_slug(publication.type, publication.document.slug)
  end

  test "should be able to retrieve documents of many types at a particular slug" do
    news = create(:draft_news_article)
    speech = create(:draft_speech)
    assert_equal news.document, Document.at_slug([news.type, speech.type], news.document.slug)
    assert_equal speech.document, Document.at_slug([news.type, speech.type], speech.document.slug)
  end

  test "should be live if a published edition exists" do
    published_publication = create(:published_publication)
    assert published_publication.document.live?
  end

  test "should be live if a withdrawn edition exists" do
    published_publication = create(:withdrawn_publication)
    assert published_publication.document.live?
  end

  test "should not be live if no published or withdrawn edition exists" do
    draft_publication = create(:draft_publication)
    assert_not draft_publication.document.live?
  end

  test "should no longer be live when it's edition is unpublished" do
    published_publication = create(:published_publication)
    assert published_publication.document.live?

    published_publication.unpublish!

    assert_not published_publication.document.live?
  end

  test "should ignore deleted editions when finding latest edition" do
    document = create(:document)
    original_edition = create(:published_edition, document:)
    _deleted_edition = create(:deleted_edition, document:)

    assert_equal original_edition, document.latest_edition
  end

  test "#pre_publication_edition returns the edition in a pre-publication state" do
    document = create(:document)
    create(:deleted_edition, document:)
    create(:published_edition, document:)
    draft_edition = create(:draft_edition, document:)

    assert_equal draft_edition, document.pre_publication_edition
  end

  test "#destroy also destroys ALL editions including those marked as deleted" do
    document = create(:document)
    original_edition = create(:published_edition, document:)
    deleted_edition = create(:deleted_edition, document:)

    document.destroy!
    assert_not Edition.unscoped.exists?(original_edition.id)
    assert_not Edition.unscoped.exists?(deleted_edition.id)
  end

  test "#destroy also destroys relations to other editions" do
    document = create(:document)
    relationship = create(:edition_relation, document:)
    document.destroy!
    assert_nil EditionRelation.find_by(id: relationship.id)
  end

  test "#destroy also destroys document collection group memberships" do
    published_edition = create(:published_edition)
    create(
      :published_document_collection,
      groups: [build(:document_collection_group, documents: [published_edition.document])],
    )

    published_edition.document.destroy!
    assert_empty DocumentCollectionGroupMembership.where(document_id: published_edition.document.id)
  end

  test "#destroy also destroys 'featured document' associations" do
    document = create(:document)
    feature = create(:feature, document:)
    feature_list = create(:feature_list, features: [feature])

    feature_list.reload
    assert_equal 1, feature_list.features.size

    document.destroy!

    feature_list.reload
    assert_equal 0, feature_list.features.size
  end

  test "should list a single change history when sole published edition is marked as a minor change" do
    edition = create(:published_publication, minor_change: true, change_note: nil)

    history = edition.change_history
    assert_equal 1, history.length
    assert_equal "First published.", history.first.note
  end

  test "returns change history" do
    document = create(:document)
    history = document.change_history

    assert_equal DocumentHistory, history.class
    assert_equal document, history.document
  end

  test "should return scheduled edition" do
    publication = create(:scheduled_publication, scheduled_publication: 1.day.from_now)
    document = publication.document

    assert_equal publication, document.scheduled_edition
  end

  test "#first_published_on_govuk returns first time it was published on GOV.UK" do
    Timecop.freeze(Time.zone.now - 3.days)
    edition = create(:submitted_edition)
    Timecop.freeze(Time.zone.now + 1.day)
    edition.major_change_published_at = Time.zone.now
    edition.publish!
    publication_date = edition.updated_at
    Timecop.freeze(Time.zone.now + 1.day)
    new_edition = edition.create_draft(edition.creator)
    new_edition.change_note = "updated"
    new_edition.submit!
    new_edition.publish!

    assert_equal publication_date, new_edition.document.first_published_on_govuk
  end

  test "has_many #editions in order of creation" do
    document = create(:document)
    [
      # Create editions in a random order to prove we don't rely on insertion order (i.e. MySQL's auto-incremented IDs)
      one_hour_ago = build(:published_edition, document:, created_at: 1.hour.ago),
      one_day_ago = build(:superseded_edition, document:, created_at: 1.day.ago),
      one_week_ago = build(:superseded_edition, document:, created_at: 1.week.ago),
    ].shuffle.map(&:save!)

    assert_equal [one_week_ago, one_day_ago, one_hour_ago], document.editions
  end

  test "#ever_published_editions returns all editions that have ever been published or withdrawn" do
    document = create(:document)
    superseded = create(:superseded_edition, document:)
    withdrawn = create(:edition, state: "withdrawn", document:)
    current = create(:published_edition, document:)

    assert_equal [superseded, withdrawn, current], document.ever_published_editions

    current.withdraw!
    assert_equal [superseded, withdrawn, current], document.reload.ever_published_editions
  end

  test "#humanized_document_type should return document type in a user friendly format" do
    assert_equal "document collection", build(:document, document_type: "DocumentCollection").humanized_document_type
  end

  test "#similar_slug_exists? returns true if a document with a similar slug exists" do
    _existing = create(:news_article, title: "Latest news")
    draft = create(:news_article, title: "Latest news")

    assert draft.document.similar_slug_exists?

    distinct_draft = create(:news_article, title: "Latest news from the crime scene")
    assert_not distinct_draft.document.similar_slug_exists?
  end

  test "#similar_slug_exists? scopes to documents of the same type" do
    _existing = create(:news_article, title: "UK prospers")
    draft = create(:speech, title: "UK prospers")

    assert_not draft.document.similar_slug_exists?
  end

  test "should have no associated needs when there are no need ids" do
    document = create(:document)
    stub_publishing_api_has_links({ content_id: document.content_id, links: {} })
    assert_equal [], document.associated_needs
  end

  test "should have associated needs when need ids are present" do
    document = create(:document)

    needs = [
      {
        content_id: SecureRandom.uuid,
        details: {
          role: "a",
          goal: "b",
          benefit: "c",
        },
      },
      {
        content_id: SecureRandom.uuid,
        details: {
          role: "d",
          goal: "e",
          benefit: "f",
        },
      },
    ]
    stub_publishing_api_has_links(
      {
        content_id: document.content_id,
        links: {
          meets_user_needs: needs.map { |need| need[:content_id] },
        },
      },
    )
    stub_publishing_api_has_expanded_links(
      {
        content_id: document.content_id,
        expanded_links: {
          meets_user_needs: needs,
        },
      },
    )

    assert_equal needs.first[:content_id], document.associated_needs.first["content_id"]
    assert_equal needs.last[:content_id], document.associated_needs.last["content_id"]
  end

  test "#patch_meets_user_needs_links should send needs ids to Publishing API" do
    document = create(:document)
    need_content_ids = [SecureRandom.uuid, SecureRandom.uuid]
    document.stubs(:need_ids).returns(need_content_ids)

    Services.publishing_api.stubs(:patch_links)
        .with(document.content_id, links: { meets_user_needs: need_content_ids })
        .returns("Links updated")

    Services.publishing_api.expects(:patch_links)
        .with(document.content_id, links: { meets_user_needs: need_content_ids })
        .returns("Links updated")

    assert_equal document.patch_meets_user_needs_links, "Links updated"
  end

  test "#withdrawals returns withdrawals that have happened on editions of the document" do
    document = create(:document)
    create_list(:withdrawn_edition, 3, document:)
    create(:published_edition, document:)

    # Create a decoy withdrawal on a different document
    create(:withdrawn_edition)

    assert_equal 3, document.withdrawals.count
    assert_equal 4, Unpublishing.count
  end

  test "#withdrawals are ordered by withdrawal date, ascending" do
    document = create(:document)
    create_list(:withdrawn_edition, 10, document:) do |edition|
      # Assign random unpublished_at dates in the past
      random_date = rand(3.years.ago..1.week.ago)
      edition.unpublishing.update! unpublished_at: random_date
    end

    withdrawals = document.withdrawals

    assert withdrawals.first.unpublished_at < withdrawals.last.unpublished_at
    assert_equal withdrawals.sort_by(&:unpublished_at), withdrawals.to_a
  end

  test "#update_edition_references updates latest_edition_id and live_edition_id" do
    Edition.any_instance.stubs(:update_document_edition_references)

    # 1. Create a draft
    document = create(:document)
    first_edition = create(:draft_edition, document:)
    document.update_edition_references
    assert_equal first_edition.id, document.latest_edition_id
    assert_nil document.live_edition_id

    # 2. Publish it
    force_publish(first_edition)
    document.update_edition_references
    assert_equal first_edition.id, document.latest_edition_id
    assert_equal first_edition.id, document.live_edition_id

    # 3. Create a new draft
    second_edition = first_edition.create_draft(create(:user))
    document.update_edition_references
    assert_equal second_edition.id, document.latest_edition_id
    assert_equal first_edition.id, document.live_edition_id

    # 4. Publish the new draft
    second_edition.minor_change = true
    force_publish(second_edition)
    document.update_edition_references
    assert_equal second_edition.id, document.latest_edition_id
    assert_equal second_edition.id, document.live_edition_id
  end

  test '#update_edition_references ignores "deleted" editions' do
    Edition.any_instance.stubs(:update_document_edition_references)

    document = create(:document)
    edition = create(:published_edition, document:)
    create(:deleted_edition, document:)

    document.update_edition_references
    assert_equal edition.id, document.latest_edition_id
    assert_equal edition.id, document.live_edition_id
  end

  test '#live_edition is a "published" or "withdrawn" edition' do
    published = create(:published_edition)
    withdrawn = create(:withdrawn_edition)
    unpublished = create(:unpublished_edition)
    draft = create(:draft_edition)

    assert_equal published, published.document.live_edition
    assert_equal withdrawn, withdrawn.document.live_edition
    assert_nil unpublished.document.live_edition
    assert_nil draft.document.live_edition
  end

  test "#update_slug_if_possible updates the slug to the title passed maps to a diffrent slug" do
    document = build(:document)
    new_slug = "new_slug"
    document.expects(:update!).with(sluggable_string: new_slug).once

    document.update_slug_if_possible(new_slug)
  end

  test "#update_slug_if_possible does nothing to the slug if the title passed in maps to the current slug" do
    document = build_stubbed(:document)
    document.expects(:update!).never

    document.update_slug_if_possible(document.slug)
  end

  test "#update_slug_if_possible ensures that the slug is set to the documents id if the new title contains special characters" do
    document = create(:document, slug: nil)
    slug_with_special_characters = "首次中英高级别安全"

    document.update_slug_if_possible(slug_with_special_characters)

    assert_equal document.id.to_s, document.reload.slug
  end

  ["unpublished", Edition::PUBLICLY_VISIBLE_STATES, Edition::PRE_PUBLICATION_STATES].flatten.each do |edition_state|
    test "#has_republishable_editions? returns true when there's an #{edition_state} edition" do
      document = create(:document, editions: [build(:"#{edition_state}_edition")])
      assert_equal document.has_republishable_editions?, true
    end
  end

  Edition::FROZEN_STATES.each do |edition_state|
    test "#has_republishable_editions? returns false when there are only editions with a state #{edition_state}" do
      document = create(:document, editions: [build(:"#{edition_state}_edition")])
      assert_equal document.has_republishable_editions?, false
    end
  end

  test "#has_republishable_editions? returns false when there are no editions" do
    document = create(:document, editions: [])
    assert_equal document.has_republishable_editions?, false
  end

  test "#latest_unpublished_edition returns the latest unpublished edition when one exists" do
    unpublished_edition_2 = build(:unpublished_edition)

    document = create(:document, editions: [build(:unpublished_edition), unpublished_edition_2, build(:draft_edition)])

    assert_equal document.latest_unpublished_edition, unpublished_edition_2
  end

  test "#latest_unpublished_edition returns nil when there are no unpublished editions" do
    document = create(:document, editions: [build(:draft_edition)])

    assert_nil document.latest_unpublished_edition
  end

  test "#published_edition returns the published edition when one exists" do
    published_edition = build(:published_edition)

    document = create(:document, editions: [published_edition, build(:draft_edition)])

    assert_equal document.published_edition, published_edition
  end

  test "#published_edition returns nil when there is no published edition" do
    document = create(:document, editions: [build(:draft_edition)])

    assert_nil document.published_edition
  end

  test "#withdrawn_edition returns the withdrawn edition when one exists" do
    withdrawn_edition = build(:withdrawn_edition)

    document = create(:document, editions: [withdrawn_edition, build(:draft_edition)])

    assert_equal document.withdrawn_edition, withdrawn_edition
  end

  test "#withdrawn_edition returns nil when there is no withdrawn edition" do
    document = create(:document, editions: [build(:draft_edition)])

    assert_nil document.withdrawn_edition
  end

  describe "republishing editions" do
    let(:unpublished_edition_a) { build(:unpublished_edition) }
    let(:unpublished_edition_b) { build(:unpublished_edition) }
    let(:withdrawn_edition) { build(:withdrawn_edition) }
    let(:published_edition) { build(:published_edition) }
    let(:draft_edition) { build(:draft_edition) }

    let(:document) { build(:document, live_edition:, pre_publication_edition:) }

    setup do
      Document.stubs(:find).returns(document)
    end

    context "when the document only has superseded editions" do
      let(:live_edition) { nil }
      let(:pre_publication_edition) { nil }

      setup { document.editions.stubs(:unpublished).returns([]) }

      it "#republishing_actions returns no actions" do
        assert_equal document.republishing_actions, []
      end

      it "#republishable_editions returns no editions" do
        assert_equal document.republishable_editions, []
      end
    end

    context "when the document has one or more non-superseded editions" do
      context "that are unpublished" do
        let(:live_edition) { nil }
        let(:pre_publication_edition) { nil }

        setup { document.editions.stubs(:unpublished).returns([unpublished_edition_a, unpublished_edition_b]) }

        it "#republishing_actions returns an action for republishing the latest unpublished edition" do
          assert_equal document.republishing_actions, [:republish_latest_unpublished_edition]
        end

        it "#republishable_editions returns the latest unpublished edition" do
          assert_equal document.republishable_editions, [unpublished_edition_b]
        end

        context "and there's also a pre-publication edition" do
          let(:live_edition) { nil }
          let(:pre_publication_edition) { draft_edition }

          setup { document.editions.stubs(:unpublished).returns([unpublished_edition_a, unpublished_edition_b]) }

          it "#republishing_actions returns actions for republishing both the latest unpublished and pre-publication editions" do
            assert_equal document.republishing_actions, %i[republish_latest_unpublished_edition republish_pre_publication_edition]
          end

          it "#republishable_editions returns the latest unpublished and pre-publication editions" do
            assert_equal document.republishable_editions, [unpublished_edition_b, pre_publication_edition]
          end

          context "but the pre-publication edition is invalid" do
            setup { draft_edition.stubs(:valid?).returns(false) }

            it "#republishing_actions returns an action for republishing the latest unpublished edition but not the pre-publication edition" do
              assert_equal document.republishing_actions, [:republish_latest_unpublished_edition]
            end

            it "#republishable_editions returns the latest unpublished edition but not the pre-publication edition" do
              assert_equal document.republishable_editions, [unpublished_edition_b]
            end
          end
        end
      end

      context "and the live edition is withdrawn" do
        let(:live_edition) { withdrawn_edition }
        let(:pre_publication_edition) { nil }

        setup { document.editions.stubs(:unpublished).returns([]) }

        it "#republishing_actions returns an action for republishing the withdrawn edition" do
          assert_equal document.republishing_actions, %i[patch_links republish_withdrawn_edition]
        end

        it "#republishable_editions returns the withdrawn edition" do
          assert_equal document.republishable_editions, [withdrawn_edition]
        end
      end

      context "none of which are unpublished or withdrawn" do
        let(:live_edition) { nil }
        let(:pre_publication_edition) { draft_edition }

        context "and there's only a pre-publication edition" do
          setup { document.editions.stubs(:unpublished).returns([]) }

          it "#republishing_actions returns actions for patching links then republishing the pre-publication edition" do
            assert_equal document.republishing_actions, %i[patch_links republish_pre_publication_edition]
          end

          it "#republishable_editions returns the pre-publication edition" do
            assert_equal document.republishable_editions, [pre_publication_edition]
          end

          context "but the pre-publication edition is invalid" do
            setup { draft_edition.stubs(:valid?).returns(false) }

            it "#republishing_actions returns an action for patching links but not republishing the pre-publication edition" do
              assert_equal document.republishing_actions, [:patch_links]
            end

            it "#republishable_editions returns no editions" do
              assert_equal document.republishable_editions, []
            end
          end
        end

        context "and there's only a published edition" do
          let(:live_edition) { published_edition }
          let(:pre_publication_edition) { nil }

          setup { document.editions.stubs(:unpublished).returns([]) }

          it "#republishing_actions returns actions for patching links then republishing the published edition" do
            assert_equal document.republishing_actions, %i[patch_links republish_published_edition]
          end

          it "#republishable_editions returns the published edition" do
            assert_equal document.republishable_editions, [published_edition]
          end
        end

        context "and there's both a published and pre-publication edition" do
          let(:live_edition) { published_edition }
          let(:pre_publication_edition) { draft_edition }

          setup { document.editions.stubs(:unpublished).returns([]) }

          it "#republishing_actions returns actions for patching links then republishing the published then pre-publication editions" do
            assert_equal document.republishing_actions, %i[patch_links republish_published_edition republish_pre_publication_edition]
          end

          it "#republishable_editions returns the published and pre-publication editions" do
            assert_equal document.republishable_editions, [published_edition, pre_publication_edition]
          end

          context "but the draft edition is invalid" do
            setup { draft_edition.stubs(:valid?).returns(false) }

            it "#republishing_actions returns actions for patching links then republishing the published edition but not the pre-publication edition" do
              assert_equal document.republishing_actions, %i[patch_links republish_published_edition]
            end

            it "#republishable_editions returns the published but not pre-publication edition" do
              assert_equal document.republishable_editions, [published_edition]
            end
          end
        end
      end
    end
  end
end
