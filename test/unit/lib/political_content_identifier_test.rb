require "test_helper"

class PoliticalContentIdentifierTest < ActiveSupport::TestCase
  test "fatality notices are never political, even when associated with a minister" do
    fatality_notice = create(
      :fatality_notice,
      role_appointments: [create(:ministerial_role_appointment)],
    )

    assert_not political?(fatality_notice)
  end

  test "statistics publications are never political, even when associated with a minister" do
    statistics_publication = create(
      :publication,
      :statistics,
      role_appointments: [create(:ministerial_role_appointment)],
    )

    assert_not political?(statistics_publication)
  end

  test "world-news-stories are always political" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("world_news_story"))
    world_news_story = create(:standard_edition, configurable_document_type: "world_news_story")

    assert political?(world_news_story)
  end

  test "political formats associated with a political orgs are political" do
    political_organisation = create(:organisation, :political)
    edition = create(:consultation, lead_organisations: [political_organisation])

    assert political?(edition)
  end

  test "config-driven formats that can be marked as political, and associated with a political org, are political" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type(
        "test_type",
        {
          "associations" => [{ "key" => "organisations" }],
          "settings" => { "history_mode_enabled" => true },
        },
      ),
    )
    edition = build(:standard_edition)
    edition.edition_organisations.build([{ organisation: create(:organisation, :political), lead: true }])
    edition.save!

    assert political?(edition)
  end

  test "political formats not associated with political orgs are not political" do
    non_political_organisation = create(:organisation, :non_political)
    edition = create(:consultation, lead_organisations: [non_political_organisation])

    assert_not political?(edition)
  end

  test "non-political formats associated with political orgs are not political" do
    political_organisation = create(:organisation, :political)
    edition = create(:detailed_guide, lead_organisations: [political_organisation])

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
