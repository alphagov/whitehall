require "test_helper"

class Admin::EditionTagsControllerTest < ActionController::TestCase
  include TaxonomyHelper
  include Admin::EditionRoutesHelper
  should_be_an_admin_controller

  setup do
    @user = login_as(:departmental_editor)
    @publishing_api_endpoint = GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT
    organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")
    @edition = create(:publication, organisations: [organisation])
    stub_taxonomy_with_all_taxons
    stub_taxonomy_with_world_taxons
  end

  def stub_publishing_api_links_with_taxons(content_id, taxons)
    stub_publishing_api_has_links(
      {
        "content_id" => content_id,
        "links" => {
          "taxons" => taxons,
        },
        "version" => 1,
      },
    )
  end

  test "should return an error on a version conflict" do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [child_taxon])

    publishing_api_patch_request = stub_request(:patch, "#{@publishing_api_endpoint}/links/#{@edition.content_id}")
      .to_return(status: 409)

    put :update, params: { edition_id: @edition, taxonomy_tag_form: { previous_version: 1, taxons: [child_taxon_content_id] } }

    assert_requested publishing_api_patch_request
    assert_redirected_to edit_admin_edition_tags_path(@edition)
    assert_equal "Somebody changed the tags before you could. Your changes have not been saved.", flash[:alert]
  end

  test "should post taxons to publishing-api" do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update, params: { edition_id: @edition, taxonomy_tag_form: { taxons: [child_taxon_content_id], previous_version: 1 } }

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: {
        taxons: [child_taxon_content_id],
      },
      previous_version: "1",
    )
  end

  test 'should redirect to edition admin page when "Save Tagging Changes" is clicked' do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update,
        params: {
          edition_id: @edition,
          taxonomy_tag_form: { taxons: [child_taxon_content_id], previous_version: 1 },
          save: "Some Value",
        }

    assert_redirected_to @controller.admin_edition_path(@edition)
  end

  test 'should redirect to legacy associations page when "Legacy tags" is clicked' do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update,
        params: {
          edition_id: @edition,
          taxonomy_tag_form: { taxons: [child_taxon_content_id], previous_version: 1 },
          legacy_tags: "Some Value",
        }

    assert_redirected_to edit_admin_edition_legacy_associations_path(@edition, return: :tags)
  end

  test "should post empty array to publishing api if no taxons are selected" do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update, params: { edition_id: @edition, taxonomy_tag_form: { previous_version: 1 } }

    assert_publishing_api_patch_links(@edition.content_id, links: { taxons: [] }, previous_version: "1")
  end

  view_test "should check a child taxon and its parents when only a child taxon is returned" do
    stub_publishing_api_links_with_taxons(@edition.content_id, [child_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select "input[value='#{parent_taxon_content_id}'][checked='checked']"
    assert_select "input[value='#{child_taxon_content_id}'][checked='checked']"
  end

  view_test "should check a parent taxon but not its children when only a parent taxon is returned" do
    stub_publishing_api_links_with_taxons(@edition.content_id, [parent_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select "input[value='#{parent_taxon_content_id}'][checked='checked']"
    refute_select "input[value='#{child_taxon_content_id}'][checked='checked']"
  end

  view_test "keep invisible taxon mappings" do
    stub_publishing_api_links_with_taxons(
      @edition.content_id,
      [
        child_taxon_content_id,
        draft_taxon_1_content_id,
        "invisible_taxon_1_content_id",
        "invisible_taxon_2_content_id",
      ],
    )

    get :edit, params: { edition_id: @edition }

    assert_select "input[name='taxonomy_tag_form[invisible_taxons]'][value='invisible_taxon_1_content_id,invisible_taxon_2_content_id']"
  end

  def assert_tracking_attributes(element:, track_label:)
    assert_equal "gem-track-click", element["data-module"]
    assert_equal "form-button", element["data-track-category"]
    assert_equal track_label, element["data-track-label"]
  end

  view_test "should render save button with tracking attributes" do
    stub_publishing_api_links_with_taxons(@edition.content_id, [parent_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select "button[name*='save']" do |elements|
      assert_equal 1, elements.length
      assert_tracking_attributes(
        element: elements.first,
        track_label: "Save tagging changes",
      )
    end
  end

  view_test "should render save and review legacy button with tracking attributes" do
    stub_publishing_api_links_with_taxons(@edition.content_id, [parent_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select "button[name*='legacy_tags']" do |elements|
      assert_equal 1, elements.length
      assert_tracking_attributes(
        element: elements.first,
        track_label: "Save and review specialist topic tagging",
      )
    end
  end

  test "should post invisible taxons to publishing-api" do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update,
        params: {
          edition_id: @edition,
          taxonomy_tag_form: {
            taxons: [child_taxon_content_id],
            invisible_taxons: "invisible_taxon_1_content_id",
            previous_version: 1,
          },
        }

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: {
        taxons: [
          child_taxon_content_id,
          "invisible_taxon_1_content_id",
        ],
      },
      previous_version: "1",
    )
  end

  test "should also post taxons tagged to the topic and world taxonomies" do
    organisation = create(:organisation, content_id: "f323e83c-868b-4bcb-b6e2-a8f9bb40397e")
    @world_and_topic_edition = create(:publication, publication_type: PublicationType::Guidance, organisations: [organisation])

    stub_publishing_api_expanded_links_with_taxons(@world_and_topic_edition.content_id, [world_child_taxon])

    put :update,
        params: {
          edition_id: @world_and_topic_edition,
          taxonomy_tag_form: {
            taxons: [child_taxon_content_id],
            previous_version: 1,
          },
        }

    assert_publishing_api_patch_links(
      @world_and_topic_edition.content_id,
      links: {
        taxons: [child_taxon_content_id, world_child_taxon_content_id],
      },
      previous_version: "1",
    )
  end

  view_test "should render the correct fields" do
    stub_publishing_api_links_with_taxons(@edition.content_id, [parent_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select ".govuk-caption-xl", @edition[:title]
    assert_select "h1", "Topic taxonomy tags"
    assert_select "h2", "Selected topics"
    assert_select "miller-columns", count: 1
    assert_select "miller-columns-selected", count: 1
  end
end
