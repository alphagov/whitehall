require "test_helper"

class Document::NeedsTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "should have no associated needs when there are no need ids" do
    document = create(:document)
    publishing_api_has_links(content_id: document.content_id, links: {})
    assert_equal [], document.associated_needs
  end

  test "should have associated needs when need ids are present" do
    document = create(:document)

    needs = [
        {
            content_id: SecureRandom.uuid,
            details: {
                role: "a",
                goal: "b",
                benefit: "c",
            }
        },
        {
            content_id: SecureRandom.uuid,
            details: {
                role: "d",
                goal: "e",
                benefit: "f",
            }
        }
    ]
    publishing_api_has_links(
      content_id: document.content_id,
      links: {
          meets_user_needs: needs.map { |need| need[:content_id] }
      }
    )
    publishing_api_has_expanded_links(
      content_id: document.content_id,
      expanded_links: {
          meets_user_needs: needs
      }
    )

    assert_equal needs.first[:content_id], document.associated_needs.first["content_id"]
    assert_equal needs.last[:content_id], document.associated_needs.last["content_id"]
  end

  test "#patch_meets_user_needs_links should send needs ids to Publishing API" do
    document = create(:document)
    need_content_ids = [SecureRandom.uuid, SecureRandom.uuid]
    document.stubs(:need_ids).returns(need_content_ids)

    need_content_ids = need_content_ids
    Services.publishing_api.stubs(:patch_links)
        .with(document.content_id, links: { meets_user_needs: need_content_ids })
        .returns("Links updated")

    Services.publishing_api.expects(:patch_links)
        .with(document.content_id, links: { meets_user_needs: need_content_ids })
        .returns("Links updated")

    assert_equal document.patch_meets_user_needs_links, "Links updated"
  end

  test "#get_user_needs_from_publishing_api returns an empty array for a 404 response" do
    document = create(:document)

    Services.publishing_api.expects(:get_links)
    .with(document.content_id)
    .raises(GdsApi::HTTPNotFound.new(404))

    assert_equal document.get_user_needs_from_publishing_api, []
  end

  # This can happen when a document is associated with a need_id that is unpublished.
  # Then publishing_ap.get_links will have ["links"]["meets_user_needs"], but
  # publishing_api.get_expanded_links will not have ["expanded_links"]["meets_user_needs"]
  test "#associated_needs returns empty array when ['expanded_links']['meets_user_needs'] is nil" do
    document = create(:document)

    document.stubs(:get_user_needs_from_publishing_api)
      .returns(%w[f5f42227-b7c6-4543-bb30-68379f29aa40])

    Services
      .publishing_api
      .stubs(:get_expanded_links)
      .with(document.content_id)
      .returns(
        "expanded_links" => {
          "an_expanded_link" => [
            {
              "key" => "value",
            },
          ],
        }
      )

    expected_array = Array.new
    assert_equal expected_array, document.associated_needs
  end
end
