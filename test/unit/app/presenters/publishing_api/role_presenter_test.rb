require "test_helper"

class PublishingApi::RolePresenterTest < ActionView::TestCase
  def present(...)
    PublishingApi::RolePresenter.new(...)
  end

  test "presents a Ministerial Role ready for adding to the Publishing API" do
    organisation = create(:organisation)
    role = create(
      :ministerial_role,
      organisations: [organisation],
      responsibilities: "X and Y",
    )

    expected_hash = {
      base_path: "/government/ministers/#{role.slug}",
      title: role.name,
      description: "X and Y",
      schema_name: "role",
      document_type: "ministerial_role",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "collections",
      public_updated_at: role.updated_at,
      routes: [
        {
          path: "/government/ministers/#{role.slug}",
          type: "exact",
        },
      ],
      redirects: [],
      update_type: "major",
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: "X and Y",
          },
        ],
        attends_cabinet_type: role.attends_cabinet_type,
        role_payment_type: role.role_payment_type,
        supports_historical_accounts: role.supports_historical_accounts,
        seniority: 100,
        whip_organisation: {},
      },
    }
    expected_links = {
      ordered_parent_organisations: [organisation.content_id],
    }

    presented_item = present(role)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal role.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "role")
    assert_valid_against_links_schema({ links: presented_item.links }, "role")
  end

  test "presents a Ministerial Whip Role ready for adding to the Publishing API" do
    organisation = create(:organisation)
    role = create(
      :ministerial_role,
      organisations: [organisation],
      responsibilities: "X and Y",
      whip_organisation_id: 1,
    )

    expected_hash = {
      base_path: "/government/ministers/#{role.slug}",
      title: role.name,
      description: "X and Y",
      schema_name: "role",
      document_type: "ministerial_role",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "collections",
      public_updated_at: role.updated_at,
      routes: [
        {
          path: "/government/ministers/#{role.slug}",
          type: "exact",
        },
      ],
      redirects: [],
      update_type: "major",
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: "X and Y",
          },
        ],
        attends_cabinet_type: role.attends_cabinet_type,
        role_payment_type: role.role_payment_type,
        supports_historical_accounts: role.supports_historical_accounts,
        seniority: 100,
        whip_organisation: {
          sort_order: 1,
          label: "House of Commons",
        },
      },
    }
    expected_links = {
      ordered_parent_organisations: [organisation.content_id],
    }

    presented_item = present(role)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal role.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "role")
    assert_valid_against_links_schema({ links: presented_item.links }, "role")
  end

  test "presents a Board Member Role ready for adding to the Publishing API" do
    role = create(:board_member_role, responsibilities: "Y and Z")

    expected_hash = {
      base_path: nil,
      title: role.name,
      description: "Y and Z",
      schema_name: "role",
      document_type: "board_member_role",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "collections",
      public_updated_at: role.updated_at,
      routes: [],
      redirects: [],
      update_type: "major",
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: "Y and Z",
          },
        ],
        attends_cabinet_type: role.attends_cabinet_type,
        role_payment_type: role.role_payment_type,
        supports_historical_accounts: role.supports_historical_accounts,
        whip_organisation: {},
      },
    }

    presented_item = present(role)

    assert_equal expected_hash, presented_item.content
  end

  test "presents the correct routes for a role with a translation" do
    role = create(
      :role,
      translated_into: [:cy],
    )

    expected_base_path = role.public_path

    I18n.with_locale(:en) do
      presented_item = PublishingApi::RolePresenter.new(role)

      assert_equal expected_base_path, presented_item.content[:base_path]

      assert_equal [
        { path: expected_base_path, type: "exact" },
      ], presented_item.content[:routes]
    end

    I18n.with_locale(:cy) do
      presented_item = PublishingApi::RolePresenter.new(role)

      assert_equal "#{expected_base_path}.cy", presented_item.content[:base_path]

      assert_equal [
        { path: "#{expected_base_path}.cy", type: "exact" },
      ], presented_item.content[:routes]
    end
  end
end
