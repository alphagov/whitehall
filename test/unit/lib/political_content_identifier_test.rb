require "test_helper"

class PoliticalContentIdentifierTest < ActiveSupport::TestCase
  test "fatality notices are never marked political, even when associated with a minister" do
    fatality_notice = create(
      :fatality_notice,
      role_appointments: [create(:ministerial_role_appointment)],
    )

    assert_not political?(fatality_notice)
  end

  test "statistics publications are never marked political, even when associated with a minister" do
    statistics_publication = create(
      :publication,
      :statistics,
      role_appointments: [create(:ministerial_role_appointment)],
    )

    assert_not political?(statistics_publication)
  end

  test "world-news-stories are always political" do
    ConfigurableDocumentType
      .setup_test_types(build_configurable_document_type("world_news_story", { "settings" => { "history_mode" => { "enabled" => true } } }))
    world_news_story = create(:standard_edition, configurable_document_type: "world_news_story")

    assert political?(world_news_story)
  end

  test "legacy formats whitelisted for marking by the system are political when associated with at least one political org" do
    political_organisation = create(:organisation, :political)
    non_political_organisation = create(:organisation, political: false)
    edition = create(:consultation, lead_organisations: [political_organisation, non_political_organisation])

    assert political?(edition)
  end

  test "config-driven formats whitelisted for marking by the system are political when associated with at least one political org" do
    ConfigurableDocumentType
      .setup_test_types(
        build_configurable_document_type(
          "test_type",
          {
            "forms" => {
              "documents" => {
                "fields" => {
                  "lead_organisations" => {
                    "attribute_path" => %w[lead_organisation_ids],
                    "translatable" => true,
                    "block" => "ordered_select_with_search_tagging",
                  },
                },
              },
            },
            "settings" => {
              "history_mode" => {
                "enabled" => true,
                "can_be_marked_political_by_system_based_on_organisation" => true,
              },
            },
          },
        ),
      )

    edition = create(:standard_edition)
    political_organisation = create(:organisation, :political)
    non_political_organisation = create(:organisation, political: false)
    edition.edition_organisations.build([{ organisation: political_organisation, lead: true }, { organisation: non_political_organisation, lead: true }])
    edition.save!

    assert political?(edition)
  end

  test "legacy formats whitelisted for marking by the system are not political when associated with non-political orgs" do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:consultation, lead_organisations: [non_political_organisation])

    assert_not political?(edition)
  end

  test "config-driven formats whitelisted for marking by the system are not political when associated with a non-political org" do
    ConfigurableDocumentType
      .setup_test_types(
        build_configurable_document_type(
          "test_type",
          {
            "forms" => {
              "documents" => {
                "fields" => {
                  "lead_organisations" => {
                    "attribute_path" => %w[lead_organisation_ids],
                    "translatable" => true,
                    "block" => "ordered_select_with_search_tagging",
                  },
                },
              },
            },
            "settings" => {
              "history_mode" => {
                "enabled" => true,
                "can_be_marked_political_by_system_based_on_organisation" => true,
              },
            },
          },
        ),
      )

    edition = create(:standard_edition)
    edition.edition_organisations.build([{ organisation: create(:organisation, political: false), lead: true }])
    edition.save!

    assert_not political?(edition)
  end

  test "legacy formats not whitelisted for marking by the system are not political when associated with political orgs" do
    political_organisation = create(:organisation, :political)
    edition = create(:detailed_guide, lead_organisations: [political_organisation])

    assert_not political?(edition)
  end

  test "config-driven formats not whitelisted for marking by the system are not political when associated with a political organisation" do
    ConfigurableDocumentType
      .setup_test_types(
        build_configurable_document_type(
          "test_type",
          {
            "forms" => {
              "documents" => {
                "fields" => {
                  "lead_organisations" => {
                    "attribute_path" => %w[lead_organisation_ids],
                    "translatable" => true,
                    "block" => "ordered_select_with_search_tagging",
                  },
                },
              },
            },
            "settings" => {
              "history_mode" => {
                "enabled" => true,
                "can_be_marked_political_by_system_based_on_organisation" => false,
              },
            },
          },
        ),
      )

    edition = create(:standard_edition)
    edition.edition_organisations.build([{ organisation: create(:organisation, :political), lead: true }])
    edition.save!

    assert_not political?(edition)
  end

  test "publications of a political sub-type associated with political orgs are political" do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :policy_paper, lead_organisations: [political_organisation])

    assert political?(edition)
  end

  test "publications of a non-political sub-type associated with political orgs are not political" do
    political_organisation = create(:organisation, :political)
    edition = create(:publication, :guidance, lead_organisations: [political_organisation])

    assert_not political?(edition)
  end

  test "publications of a non-political sub-type associated with ministers are political" do
    edition = create(:publication, publication_type_id: PublicationType::Correspondence.id, role_appointments: [create(:ministerial_role_appointment)])

    assert political?(edition)
  end

  test "political formats associated with ministers are political" do
    edition = create(:publication, role_appointments: [create(:ministerial_role_appointment)])

    assert political?(edition)
  end

private

  def political?(edition)
    PoliticalContentIdentifier.political?(edition)
  end
end
