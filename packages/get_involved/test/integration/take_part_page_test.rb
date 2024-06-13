require "test_helper"
require "gds_api/test_helpers/publishing_api"

class TakePartPageTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
    @take_part_page = build(:take_part_page)

    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id_s300", "name" => "s300_minister-of-funk.960x640.jpg")
  end

  test "TakePartPage is published to Publishing API on save and republished when images finish uploading" do
    publish_count_from_after_commit = 1
    republish_count_from_create_asset_worker = 7

    Sidekiq::Testing.inline! do
      publish_presenter = PublishingApiPresenters.presenter_for(@take_part_page)
      republish_presenter = PublishingApiPresenters.presenter_for(@take_part_page, { update_type: "republish" })
      @take_part_page.save!

      # This is to simulate what the time public timestamp will be after the page has been published
      expected_publish_json = publish_presenter.content.merge public_updated_at: Time.zone.now.as_json
      expected_republish_json = republish_presenter.content.merge public_updated_at: Time.zone.now.as_json

      assert_publishing_api_put_content(@take_part_page.content_id, expected_publish_json, publish_count_from_after_commit)
      assert_publishing_api_put_content(@take_part_page.content_id, expected_republish_json, republish_count_from_create_asset_worker)
      assert_publishing_api_publish(
        @take_part_page.content_id,
        { update_type: nil, locale: "en" },
        republish_count_from_create_asset_worker + publish_count_from_after_commit,
      )
    end
  end

  test "TakePartPage publishes gone route to the Publishing API on destroy" do
    Sidekiq::Testing.inline! do
      @take_part_page.save!

      gone_request = stub_publishing_api_unpublish(
        @take_part_page.content_id,
        body: {
          type: "gone",
          locale: "en",
          discard_drafts: true,
        },
      )

      @take_part_page.destroy!

      assert_requested gone_request
    end
  end

  test "TakePartPage is published to the Publishing API when updated" do
    @take_part_page.save!
    publish_count_after_save = 1

    @take_part_page.attributes = { title: "New Title" }
    @take_part_page.save!
    publish_count_after_save += 1

    presenter = PublishingApiPresenters.presenter_for(@take_part_page)

    expected_json = presenter.content.merge(
      # This is to simulate what the time public timestamp will be after the
      # page has been published
      public_updated_at: Time.zone.now.as_json,
    )

    assert_publishing_api_put_content(@take_part_page.content_id, expected_json)
    assert_publishing_api_publish(
      @take_part_page.content_id,
      { update_type: nil,
        locale: "en" },
      publish_count_after_save,
    )
  end
end
