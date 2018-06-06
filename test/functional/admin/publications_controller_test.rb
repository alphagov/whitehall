require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  include TaxonomyHelper
  include PolicyTaggingHelpers
  setup do
    @organisation = create(:organisation)
    @user = create(:writer, organisation: @organisation)
    login_as @user
    stub_taxonomy_with_world_taxons
  end

  should_be_an_admin_controller

  should_allow_creating_of :publication
  should_allow_editing_of :publication

  should_allow_speed_tagging_of :publication
  should_allow_related_policies_for :publication
  should_allow_organisations_for :publication
  should_allow_references_to_statistical_data_sets_for :publication
  should_allow_attached_images_for :publication
  should_allow_association_between_world_locations_and :publication
  should_prevent_modification_of_unmodifiable :publication
  should_allow_alternative_format_provider_for :publication
  should_allow_scheduled_publication_of :publication
  should_allow_access_limiting_of :publication

  view_test "new displays publication fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name*='edition[first_published_at']", count: 5
      assert_select "select[name='edition[publication_type_id]']"
      assert_select "input[name='edition[access_limited]']"
    end
  end

  test 'GET :new pre-fills the pubication when a statistics announcement id is provided' do
    statistics_announcement = create(:statistics_announcement)
    get :new, params: { statistics_announcement_id: statistics_announcement.id }

    assert_equal statistics_announcement.id, assigns(:edition).statistics_announcement_id
    assert_equal statistics_announcement.title, assigns(:edition).title
    assert_equal statistics_announcement.summary, assigns(:edition).summary
    assert_equal statistics_announcement.publication_type, assigns(:edition).publication_type
    assert_equal statistics_announcement.topics, assigns(:edition).topics
    assert_equal statistics_announcement.release_date.to_i, assigns(:edition).scheduled_publication.to_i
  end

  test 'POST :create with an statistics announcement id assigns the publication to the announcement' do
    statistics_announcement = create(:statistics_announcement)
    post :create, params: {
      edition: controller_attributes_for(:publication,
        publication_type_id: PublicationType::OfficialStatistics.id,
        lead_organisation_ids: [@organisation.id],
        statistics_announcement_id: statistics_announcement.id)
    }

    publication = Publication.last

    assert publication.present?, assigns(:edition).errors.full_messages.inspect
    assert_redirected_to edit_admin_edition_legacy_associations_path(publication.id, return: :edit)
    assert_equal publication, statistics_announcement.reload.publication
  end

  test "create should create a new publication" do
    post :create, params: {
      edition: controller_attributes_for(:publication,
        first_published_at: Time.zone.parse("2001-10-21 00:00:00"),
        publication_type_id: PublicationType::ResearchAndAnalysis.id)
    }

    created_publication = Publication.last
    assert_equal Time.zone.parse("2001-10-21 00:00:00"), created_publication.first_published_at
    assert_equal PublicationType::ResearchAndAnalysis, created_publication.publication_type
  end

  test "should validate previously_published field on create" do
    post :create, params: { edition: controller_attributes_for(:publication).except(:previously_published) }
    assert_equal "You must specify whether the document has been published before", assigns(:edition).errors.full_messages.last
  end

  test "should validate first_published_at field on create if previously_published is true" do
    post :create, params: { edition: controller_attributes_for(:publication).merge(previously_published: 'true') }
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

    put :update, params: { id: publication, edition: {
      first_published_at: Time.zone.parse("2001-06-18 00:00:00")
    } }

    saved_publication = publication.reload
    assert_equal Time.zone.parse("2001-06-18 00:00:00"), saved_publication.first_published_at
  end

  view_test "should remove the publish buttons if the edition breaks the rules permitting publishing" do
    # This applies to all editions but can't be tested in the editions controller test due to redirects.
    # After conversation with DH I picked publications arbitrarily.
    login_as(create(:departmental_editor))
    publication = create(:draft_publication)

    [EditionPublisher, EditionForcePublisher].each do |publisher|
      publisher.any_instance.stubs(:failure_reasons).returns(["This edition is not dope enough"])
    end

    get :show, params: { id: publication.id }

    assert_response :success
    refute_select ".publish"
    refute_select ".force-publish"
  end

  test "prevents CRUD operations on access-limited publications" do
    my_organisation = create(:organisation)
    other_organisation = create(:organisation)
    login_as(create(:user, organisation: my_organisation))
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    get :show, params: { id: inaccessible }
    assert_response :forbidden

    get :edit, params: { id: inaccessible }
    assert_response :forbidden

    put :update, params: { id: inaccessible, edition: { summary: "new-summary" } }
    assert_response :forbidden

    delete :destroy, params: { id: inaccessible }
    assert_response :forbidden
  end

  view_test "when edition is not from DfE or SFA dont show a button to tag to the new taxonomy" do
    draft_edition = create(:draft_publication)

    publication_has_no_expanded_links(draft_edition.content_id)
    get :show, params: { id: draft_edition }

    refute_select '.taxonomy-topics'
  end

  view_test "when edition is from DfE show a button to tag to the new taxonomy" do
    dfe_organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")

    publication = create(
      :publication,
      organisations: [dfe_organisation]
    )

    login_as(create(:user, organisation: dfe_organisation))

    publication_has_no_expanded_links(publication.content_id)
    get :show, params: { id: publication }

    assert_select '.taxonomy-topics .btn', "Add topic"
  end

  view_test "when edition is from SFA show a button to tag to the new taxonomy" do
    sfa_organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")

    publication = create(
      :publication,
      organisations: [sfa_organisation]
    )

    login_as(create(:user, organisation: sfa_organisation))

    publication_has_no_expanded_links(publication.content_id)
    get :show, params: { id: publication }

    assert_select '.taxonomy-topics .btn', "Add topic"
  end

  view_test "when edition is not tagged to the new taxonomy" do
    world_tagging_organisation = create(:organisation, content_id: "f323e83c-868b-4bcb-b6e2-a8f9bb40397e")

    publication = create(
      :publication,
      publication_type: PublicationType::Guidance,
      organisations: [world_tagging_organisation]
    )

    login_as(create(:user, organisation: world_tagging_organisation))

    publication_has_no_expanded_links(publication.content_id)
    get :show, params: { id: publication }

    refute_select '.taxonomy-topics .content'
    assert_select '.taxonomy-topics#topic-new-taxonomy .no-content'
    assert_select '.taxonomy-topics#world-taxonomy .no-content'
  end

  view_test "when edition is tagged to the new taxonomy" do
    world_tagging_organisation = create(:organisation, content_id: "f323e83c-868b-4bcb-b6e2-a8f9bb40397e")

    publication = create(
      :publication,
      publication_type: PublicationType::Guidance,
      organisations: [world_tagging_organisation]
    )

    login_as(create(:user, organisation: world_tagging_organisation))

    publication_has_expanded_links(publication.content_id)

    get :show, params: { id: publication }

    refute_select '.taxonomy-topics#topic-new-taxonomy .no-content'
    assert_select '.taxonomy-topics .content li', "Education, Training and Skills"
    assert_select '.taxonomy-topics .content li', "Primary Education"
    assert_select '.taxonomy-topics#world-taxonomy .no-content'
  end

  view_test "when edition is tagged to the world taxonomy" do
    world_tagging_organisation = create(:organisation, content_id: "f323e83c-868b-4bcb-b6e2-a8f9bb40397e")

    publication = create(
      :publication,
      publication_type: PublicationType::Guidance,
      organisations: [world_tagging_organisation]
    )

    login_as(create(:user, organisation: world_tagging_organisation))

    publication_has_world_expanded_links(publication.content_id)

    get :show, params: { id: publication }

    refute_select '.taxonomy-topics#world-taxonomy .no-content'
    assert_select '.taxonomy-topics .content li', "World Child Taxon"
    assert_select '.taxonomy-topics .content li', "World Grandchild Taxon"
    assert_select '.taxonomy-topics#topic-new-taxonomy .no-content'
  end

  view_test "shows summary when edition is tagged to all legacy associations" do
    stub_specialist_sectors
    organisation = create(:organisation)
    policy_area = create(:topic)
    publication = create(
      :publication,
      organisations: [organisation],
      policy_content_ids: [policy_1['content_id']],
      topic_ids: [policy_area.id],
      primary_specialist_sector_tag: 'WELLS',
      secondary_specialist_sector_tags: %w(FIELDS OFFSHORE)
    )

    login_as(create(:user, organisation: organisation))

    get :show, params: { id: publication }

    assert_select ".policies li", policy_1['title']
    assert_select ".policy-areas li", policy_area.name
    assert_selected_specialist_sectors_are_displayed
    assert_select "a[href='#{edit_admin_edition_legacy_associations_path(publication)}']", /Change Associations/
    assert_select "a[href='#{edit_admin_edition_legacy_associations_path(publication)}'] .glyphicon-edit"
  end

  view_test "shows message when edition is not tagged to any legacy associations" do
    stub_specialist_sectors
    organisation = create(:organisation)
    publication = create(
      :publication_without_policy_areas,
      organisations: [organisation],
    )

    login_as(create(:user, organisation: organisation))
    get :show, params: { id: publication }

    refute_select '.policies'
    refute_select '.policy-areas'
    refute_select '.primary-specialist-sector'
    refute_select '.secondary-specialist-sectors'
    assert_select '.no-content.no-content-bordered', 'No associations'
    assert_select "a[href='#{edit_admin_edition_legacy_associations_path(publication)}']", /Add Associations/
    assert_select "a[href='#{edit_admin_edition_legacy_associations_path(publication)}'] .glyphicon-plus-sign"
  end

private

  def stub_specialist_sectors
    publishing_api_has_linkables(
      [
        {
          'content_id' => 'WELLS',
          'internal_name' => 'Oil and Gas / Wells',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'FIELDS',
          'internal_name' => 'Oil and Gas / Fields',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'OFFSHORE',
          'internal_name' => 'Oil and Gas / Offshore',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'DISTILL',
          'internal_name' => 'Oil and Gas / Distillation',
          'publication_state' => 'draft',
        },
      ],
      document_type: 'topic'
    )
  end

  def assert_selected_specialist_sectors_are_displayed
    assert_select ".primary-specialist-sector li", 'Oil and Gas: Wells'
    assert_select ".secondary-specialist-sectors li", 'Oil and Gas: Fields'
    assert_select ".secondary-specialist-sectors li", 'Oil and Gas: Offshore'
  end

  def publication_has_no_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id: content_id,
      expanded_links: {}
    )
  end

  def publication_has_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id: content_id,
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
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
  end

  def publication_has_world_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id:  content_id,
      expanded_links:  {
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
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
