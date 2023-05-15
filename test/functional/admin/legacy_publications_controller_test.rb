require "test_helper"

class Admin::LegacyPublicationsControllerTest < ActionController::TestCase
  tests Admin::PublicationsController

  include TaxonomyHelper
  setup do
    @organisation = create(:organisation)
    @user = create(:writer, organisation: @organisation)
    login_as @user
    stub_taxonomy_with_world_taxons
  end

  legacy_should_be_an_admin_controller

  legacy_should_allow_creating_of :publication
  legacy_should_allow_editing_of :publication

  legacy_should_allow_organisations_for :publication
  legacy_should_allow_references_to_statistical_data_sets_for :publication
  legacy_should_allow_attached_images_for :publication
  legacy_should_allow_association_between_world_locations_and :publication
  legacy_should_prevent_modification_of_unmodifiable :publication
  legacy_should_allow_alternative_format_provider_for :publication
  legacy_should_allow_scheduled_publication_of :publication
  legacy_should_allow_access_limiting_of :publication

  view_test "new displays publication fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name*='edition[first_published_at']", count: 5
      assert_select "select[name='edition[publication_type_id]']"
      assert_select "input[name='edition[access_limited]']"
    end
  end

  test "GET :new pre-fills the pubication when a statistics announcement id is provided" do
    statistics_announcement = create(:statistics_announcement)
    get :new, params: { statistics_announcement_id: statistics_announcement.id }

    assert_equal statistics_announcement.id, assigns(:edition).statistics_announcement_id
    assert_equal statistics_announcement.title, assigns(:edition).title
    assert_equal statistics_announcement.summary, assigns(:edition).summary
    assert_equal statistics_announcement.publication_type, assigns(:edition).publication_type
    assert_equal statistics_announcement.release_date.to_i, assigns(:edition).scheduled_publication.to_i
  end

  test "POST :create with an statistics announcement id assigns the publication to the announcement" do
    statistics_announcement = create(:statistics_announcement)
    post :create,
         params: {
           edition: controller_attributes_for(
             :publication,
             publication_type_id: PublicationType::OfficialStatistics.id,
             lead_organisation_ids: [@organisation.id],
             statistics_announcement_id: statistics_announcement.id,
           ),
         }

    publication = Publication.last

    assert publication.present?, assigns(:edition).errors.full_messages.inspect
    assert_redirected_to edit_admin_edition_tags_path(publication.id)
    assert_equal publication, statistics_announcement.reload.publication
  end

  test "create should create a new publication" do
    post :create,
         params: {
           edition: controller_attributes_for(
             :publication,
             first_published_at: Time.zone.parse("2001-10-21 00:00:00"),
             previously_published: "true",
             publication_type_id: PublicationType::ResearchAndAnalysis.id,
           ),
         }

    created_publication = Publication.last
    assert_equal Time.zone.parse("2001-10-21 00:00:00"), created_publication.first_published_at
    assert_equal PublicationType::ResearchAndAnalysis, created_publication.publication_type
  end

  test "should validate previously_published field on create" do
    post :create, params: { edition: controller_attributes_for(:publication).except(:previously_published) }
    assert_equal "Previously published You must specify whether the document has been published before", assigns(:edition).errors.full_messages.last
  end

  test "should validate first_published_at field on create if previously_published is true" do
    post :create, params: { edition: controller_attributes_for(:publication).merge(previously_published: "true") }
    assert_equal "First published at can't be blank", assigns(:edition).errors.full_messages.last
  end

  view_test "edit displays publication fields" do
    publication = create(:publication)

    get :edit, params: { id: publication }

    assert_select "form#edit_edition" do
      assert_select "select[name='edition[publication_type_id]']"
      assert_select "select[name*='edition[first_published_at']", count: 5
    end
  end

  test "update should save modified publication attributes" do
    publication = create(:publication)

    put :update,
        params: { id: publication,
                  edition: {
                    first_published_at: Time.zone.parse("2001-06-18 00:00:00"),
                  } }

    saved_publication = publication.reload
    assert_equal Time.zone.parse("2001-06-18 00:00:00"), saved_publication.first_published_at
  end

  test "prevents CRUD operations on access-limited publications" do
    my_organisation = create(:organisation)
    other_organisation = create(:organisation)
    login_as(create(:user, organisation: my_organisation))
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    get :edit, params: { id: inaccessible }
    assert_response :forbidden

    put :update, params: { id: inaccessible, edition: { summary: "new-summary" } }
    assert_response :forbidden

    delete :destroy, params: { id: inaccessible }
    assert_response :forbidden
  end

private

  def stub_specialist_sectors
    stub_publishing_api_has_linkables(
      [
        {
          "content_id" => "WELLS",
          "internal_name" => "Oil and Gas / Wells",
          "publication_state" => "published",
        },
        {
          "content_id" => "FIELDS",
          "internal_name" => "Oil and Gas / Fields",
          "publication_state" => "published",
        },
        {
          "content_id" => "OFFSHORE",
          "internal_name" => "Oil and Gas / Offshore",
          "publication_state" => "published",
        },
        {
          "content_id" => "DISTILL",
          "internal_name" => "Oil and Gas / Distillation",
          "publication_state" => "draft",
        },
      ],
      document_type: "topic",
    )
  end

  def assert_selected_specialist_sectors_are_displayed
    assert_select ".primary-specialist-sector li", "Oil and Gas: Wells"
    assert_select ".secondary-specialist-sectors li", "Oil and Gas: Fields"
    assert_select ".secondary-specialist-sectors li", "Oil and Gas: Offshore"
  end

  def publication_has_no_expanded_links(content_id)
    stub_publishing_api_has_expanded_links(
      {
        content_id:,
        expanded_links: {},
      },
    )
  end

  def publication_has_expanded_links(content_id)
    stub_publishing_api_has_expanded_links(
      {
        content_id:,
        expanded_links: {
          "taxons" => [
            {
              "title" => "Primary Education",
              "content_id" => "aaaa",
              "base_path" => "i-am-a-taxon",
              "details" => { "visible_to_departmental_editors" => true },
              "links" => {
                "parent_taxons" => [
                  {
                    "title" => "Education, Training and Skills",
                    "content_id" => "bbbb",
                    "base_path" => "i-am-a-parent-taxon",
                    "details" => { "visible_to_departmental_editors" => true },
                    "links" => {},
                  },
                ],
              },
            },
          ],
        },
      },
    )
  end

  def publication_has_world_expanded_links(content_id)
    stub_publishing_api_has_expanded_links(
      {
        content_id:,
        expanded_links: {
          "taxons" => [
            {
              "title" => "World Grandchild Taxon",
              "content_id" => world_grandchild_taxon_content_id,
              "base_path" => "i-am-a-taxon",
              "details" => { "visible_to_departmental_editors" => true },
              "links" => {
                "parent_taxons" => [
                  {
                    "title" => "World Child Taxon",
                    "content_id" => world_child_taxon_content_id,
                    "base_path" => "i-am-a-parent-taxon",
                    "details" => { "visible_to_departmental_editors" => true },
                    "links" => {},
                  },
                ],
              },
            },
          ],
        },
      },
    )
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
