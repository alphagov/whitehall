require "test_helper"

class Admin::EditionLegacyAssociationsControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper

  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "should update the edition with the selected legacy tags" do
    @edition = create(:publication, title: "the edition")

    put :update,
        params: { edition_id: @edition.id,
                  edition: {
                    primary_specialist_sector_tag: "aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa",
                    secondary_specialist_sector_tags: %w[aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa],
                  } }
    @edition.reload
    assert_equal "aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa", @edition.primary_specialist_sector_tag
    assert_equal %w[aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa],
                 @edition.secondary_specialist_sector_tags
  end

  test "should clear the legacy tags" do
    @edition = create(
      :publication,
      title: "the edition",
      primary_specialist_sector_tag: "aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa",
      secondary_specialist_sector_tags: %w[aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa],
    )

    put :update,
        params: { edition_id: @edition.id,
                  edition: {
                    primary_specialist_sector_tag: "",
                    secondary_specialist_sector_tags: [""],
                  } }
    @edition.reload
    assert_nil @edition.primary_specialist_sector_tag
    assert_equal [], @edition.secondary_specialist_sector_tags
  end
end
