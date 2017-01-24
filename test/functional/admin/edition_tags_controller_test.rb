require 'test_helper'

class Admin::EditionTagsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @user = login_as(:departmental_editor)
  end

  test 'submit tags with a version conflict' do
    publishing_api_endpoint = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT

    organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")
    edition = create(:publication, organisations: [organisation])

    taxons = %w(84aadc14-9bca-40d9-abb6-4f21f9792a05)


    publishing_api_patch_request = stub_request(:patch, "#{publishing_api_endpoint}/links/#{edition.content_id}")
      .to_return(status: 409)

    put :update, edition_id: edition, edition_taxonomy_tag_form: { previous_version: 1, taxons: taxons }

    assert_requested publishing_api_patch_request

    assert_redirected_to edit_admin_edition_tags_path(edition)
    assert_equal "Somebody changed the tags before you could. Your changes have not been saved.", flash[:alert]
  end
end
