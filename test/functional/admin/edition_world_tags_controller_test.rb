require 'test_helper'

class Admin::EditionWorldTagsControllerTest < ActionController::TestCase
  include TaxonomyHelper
  should_be_an_admin_controller

  setup do
    @user = login_as(:departmental_editor)
    @publishing_api_endpoint = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
    @organisation = create(:organisation, content_id: "f323e83c-868b-4bcb-b6e2-a8f9bb40397e")
    @edition = create(:publication, publication_type: PublicationType::Guidance, organisations: [@organisation])
    stub_taxonomy_with_world_taxons
  end

  test 'should return an error on a version conflict' do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [world_child_taxon])

    publishing_api_patch_request = stub_request(:patch, "#{@publishing_api_endpoint}/links/#{@edition.content_id}")
      .to_return(status: 409)

    put :update, params: { edition_id: @edition, taxonomy_tag_form: { previous_version: 1, taxons: [world_child_taxon_content_id] } }

    assert_requested publishing_api_patch_request
    assert_redirected_to edit_admin_edition_world_tags_path(@edition)
    assert_equal "Somebody changed the tags before you could. Your changes have not been saved.", flash[:alert]
  end

  test 'should post world taxons to publishing-api' do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update, params: { edition_id: @edition, taxonomy_tag_form: { taxons: [world_child_taxon_content_id], previous_version: 1 } }

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: {
        taxons: [world_child_taxon_content_id]
      },
      previous_version: "1"
    )
  end

  test 'should post empty array to publishing api if no world taxons are selected' do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [])

    put :update, params: { edition_id: @edition, taxonomy_tag_form: { previous_version: 1 } }

    assert_publishing_api_patch_links(@edition.content_id, links: { taxons: [] }, previous_version: "1")
  end

  view_test 'should check a child taxon and its parents when only a child taxon is selected' do
    stub_publishing_api_links_with_taxons(@edition.content_id, [world_grandchild_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select "input[value='#{world_child_taxon_content_id}'][checked='checked']"
    assert_select "input[value='#{world_grandchild_taxon_content_id}'][checked='checked']"
  end

  view_test 'should check a parent taxon but not its children when only a parent taxon is selected' do
    stub_publishing_api_links_with_taxons(@edition.content_id, [world_child_taxon_content_id])

    get :edit, params: { edition_id: @edition }

    assert_select "input[value='#{world_child_taxon_content_id}'][checked='checked']"
    refute_select "input[value='#{world_grandchild_taxon_content_id}'][checked='checked']"
  end

  test 'should also post taxons tagged to the topic and world taxonomies' do
    stub_publishing_api_expanded_links_with_taxons(@edition.content_id, [child_taxon])

    put :update, params: {
      edition_id: @edition,
      taxonomy_tag_form: {
        taxons: [world_child_taxon_content_id],
        previous_version: 1
      }
    }

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: {
        taxons: [world_child_taxon_content_id, child_taxon_content_id]
      },
      previous_version: "1"
    )
  end
end
