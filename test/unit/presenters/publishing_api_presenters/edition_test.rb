require 'test_helper'

class PublishingApiPresenters::EditionTest < ActiveSupport::TestCase
  include GovukContentSchemaTestHelpers::TestUnit

  def present(edition, options = {})
    PublishingApiPresenters::Edition.new(edition, options)
  end

  test 'presents an Edition ready for adding to the publishing API' do
    edition = create(:published_publication,
                title: 'The title',
                summary: 'The summary',
                primary_specialist_sector_tag: 'oil-and-gas/taxation',
                secondary_specialist_sector_tags: ['oil-and-gas/licensing'])

    public_path = Whitehall.url_maker.public_document_path(edition)

    expected_hash = {
      base_path: public_path,
      title: 'The title',
      description: 'The summary',
      format: 'placeholder',
      locale: 'en',
      need_ids: [],
      public_updated_at: edition.public_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        change_note: nil,
        tags: {
          browse_pages: [],
          policies: [],
          topics: ['oil-and-gas/taxation', 'oil-and-gas/licensing']
        }
      },
    }

    presented_item = present(edition)
    assert_equal expected_hash, presented_item.content
    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'can present a draft Edition for the publishing API' do
    edition = create(:publication,
                title: 'The title',
                summary: 'The summary',
                primary_specialist_sector_tag: 'oil-and-gas/taxation',
                secondary_specialist_sector_tags: ['oil-and-gas/licensing'])

    public_path = Whitehall.url_maker.public_document_path(edition)

    expected_hash = {
      base_path: public_path,
      title: 'The title',
      description: 'The summary',
      format: 'placeholder',
      locale: 'en',
      need_ids: [],
      public_updated_at: edition.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        change_note: nil,
        tags: {
          browse_pages: [],
          policies: [],
          topics: ['oil-and-gas/taxation', 'oil-and-gas/licensing']
        }
      },
    }

    presented_item = present(edition)
    assert_equal expected_hash, presented_item.content
    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'includes the most recent change note even when the edition is only a minor change' do
    user  = create(:gds_editor)
    first = create(:published_edition)

    major = first.create_draft(user)
    major.change_note = 'This was a major change'
    force_publish(major)

    minor = major.create_draft(user)
    minor.minor_change = true
    minor.change_note = nil

    assert_equal 'This was a major change', present(minor).content[:details][:change_note]
  end

  test 'minor changes are a "minor" update type' do
    edition = create(:case_study, minor_change: true)
    assert_equal 'minor', present(edition).update_type
  end

  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    edition = create(:case_study)
    presented_item = present(edition, update_type: update_type_override)
    assert_equal update_type_override, presented_item.update_type
  end

  test 'is locale aware' do
    edition = create(:publication)

    I18n.with_locale :ur do
      edition.title = "Urdu title"
      edition.save!
      presented_item = present(edition)

      assert_equal 'ur', presented_item.content[:locale]
      assert_equal 'Urdu title', presented_item.content[:title]
      assert_equal Whitehall.url_maker.public_document_path(edition, locale: :ur),
        presented_item.content[:routes].first[:path]
    end
  end

  test "includes new policy associations" do
    edition = create(
      :publication,
      :published,
      policy_content_ids: [policy_1["content_id"]]
    )

    assert_equal ["policy-area-1", "policy-1"], present(edition).content[:details][:tags][:policies]
  end

  test "includes new policy associations with their policy areas" do
    edition = create(:publication, :published,
      policy_content_ids: [policy_1["content_id"]]
                    )

    assert_equal ["policy-area-1", "policy-1"], present(edition).content[:details][:tags][:policies]
  end

  test "includes new policy associations with their multiple policy areas" do
    edition = create(:publication, :published,
      policy_content_ids: [policy_2["content_id"]]
                    )

    assert_equal ["policy-area-1", "policy-area-2", "policy-2"], present(edition).content[:details][:tags][:policies]
  end

  test "includes all users in access limiting fields for lead and supporting orgs" do
    lead_org_1 = create(:organisation)
    lead_org_2 = create(:organisation)
    supporting_org = create(:organisation)

    edition = create(:publication,
      lead_organisations: [lead_org_1, lead_org_2],
      supporting_organisations: [supporting_org],
      access_limited: true,
                    )

    org_users = [
      create(:user, organisation: lead_org_1),
      create(:user, organisation: lead_org_2),
      create(:user, organisation: supporting_org),
    ]

    assert_equal org_users.map(&:uid).sort, present(edition).content[:access_limited][:users].sort
  end

  test "removes users with no uid" do
    lead_org = create(:organisation)

    edition = create(:publication,
      lead_organisations: [lead_org],
      access_limited: true,
                    )

    org_users = [
      create(:user, organisation: lead_org, uid: nil),
    ]

    assert_equal [], present(edition).content[:access_limited][:users]
  end

  test "does not include access limiting fields if not access limited" do
    edition = create(:publication, access_limited: false)
    assert_nil present(edition).content[:access_limited]
  end

  test "does not include access limiting fields if publicly visible" do
    edition = create(:publication, :published, access_limited: true)
    assert_nil present(edition).content[:access_limited]

    edition = create(:publication, :withdrawn, access_limited: true)
    assert_nil present(edition).content[:access_limited]

    edition = create(:publication, :draft, access_limited: true)
    refute_nil present(edition).content[:access_limited]

    edition = create(:publication, :submitted, access_limited: true)
    refute_nil present(edition).content[:access_limited]
  end
end
