require 'test_helper'

class Admin::StatisticsAnnouncementTagsControllerTest < ActionController::TestCase
  include TaxonomyHelper
  should_be_an_admin_controller

  setup do
    @user = login_as(:departmental_editor)
    @publishing_api_endpoint = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
    organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")
    @announcement = create(:statistics_announcement, organisations: [organisation])

    stub_taxonomy_with_all_taxons
  end

  def stub_publishing_api_links_with_taxons(content_id, taxons)
    publishing_api_has_links(
      "content_id" => content_id,
      "links" => {
        "taxons" => taxons
      },
      "version" => 1
    )
  end

  test 'should return an error on a version conflict' do
    publishing_api_patch_request = stub_request(:patch, "#{@publishing_api_endpoint}/links/#{@announcement.content_id}")
      .with(
        body: {
          links: { taxons: ["child"] },
          previous_version: "1"
        }
      ).to_return(status: 409)

    put :update, params: {
      statistics_announcement_id: @announcement,
      taxonomy_tag_form: { previous_version: 1, taxons: [child_taxon_content_id] }
    }

    assert_requested publishing_api_patch_request
    assert_redirected_to edit_admin_statistics_announcement_tags_path(@announcement)
    assert_equal "Somebody changed the tags before you could. Your changes have not been saved.", flash[:alert]
  end

  test 'should post taxons to publishing-api' do
    stub_publishing_api_links_with_taxons(@announcement.content_id, [])

    put :update, params: {
      statistics_announcement_id: @announcement,
      taxonomy_tag_form: { taxons: [child_taxon_content_id], previous_version: 1 }
    }

    assert_publishing_api_patch_links(
      @announcement.content_id,
      links: {
        taxons: [child_taxon_content_id]
      },
      previous_version: "1"
    )
  end

  test 'should post empty array to publishing api if no taxons are selected' do
    stub_publishing_api_links_with_taxons(@announcement.content_id, [])

    put :update, params: {
      statistics_announcement_id: @announcement,
      taxonomy_tag_form: { previous_version: 1 }
    }

    assert_publishing_api_patch_links(@announcement.content_id, links: { taxons: [] }, previous_version: "1")
  end

  view_test 'should check a child taxon and its parents when only a child taxon is returned' do
    stub_publishing_api_links_with_taxons(@announcement.content_id, [child_taxon_content_id])

    get :edit, params: { statistics_announcement_id: @announcement }

    assert_select "input[value='#{parent_taxon_content_id}'][checked='checked']"
    assert_select "input[value='#{child_taxon_content_id}'][checked='checked']"
  end

  view_test 'should check a parent taxon but not its children when only a parent taxon is returned' do
    stub_publishing_api_links_with_taxons(@announcement.content_id, [parent_taxon_content_id])

    get :edit, params: { statistics_announcement_id: @announcement }

    assert_select "input[value='#{parent_taxon_content_id}'][checked='checked']"
    refute_select "input[value='#{child_taxon_content_id}'][checked='checked']"
  end
end
