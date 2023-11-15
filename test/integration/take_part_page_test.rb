require "test_helper"
require "gds_api/test_helpers/publishing_api"

class TakePartPageTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
    @take_part_page = build(:take_part_page)

    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id_s300", "name" => "s300_minister-of-funk.960x640.jpg")
  end

  test "TakePartPage is published to the Publishing API on save" do
    republish_count_from_create_asset_worker = 7
    publish_count_from_after_commit = 1
    expected_number_of_times_published = republish_count_from_create_asset_worker + publish_count_from_after_commit

    Sidekiq::Testing.inline! do
      presenter = PublishingApiPresenters.presenter_for(@take_part_page)
      @take_part_page.save!

      expected_json = presenter.content.merge(
        # This is to simulate what the time public timestamp will be after the
        # page has been published
        public_updated_at: Time.zone.now.as_json,
      )

      assert_publishing_api_put_content(@take_part_page.content_id, expected_json, expected_number_of_times_published)
      assert_publishing_api_publish(
        @take_part_page.content_id,
        { update_type: nil,
          locale: "en" },
        expected_number_of_times_published,
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

  test "TakePartPage patches links in the correct order in the Get Involved Page when created" do
    Sidekiq::Testing.inline! do
      # Working with a specific ID
      get_involved_content_id = "dbe329f1-359c-43f7-8944-580d4742aa91"

      # Build a couple Take Part pages with different ordering
      @take_part_page.attributes = { title: "First Page", ordering: 1 }
      @take_part_page.save!

      third_take_part_page = build(:take_part_page)
      third_take_part_page.attributes = { title: "Third Page", ordering: 3 }
      third_take_part_page.save!

      assert_publishing_api_patch_links(
        get_involved_content_id,
        { links: {
          take_part_pages: [@take_part_page.content_id, third_take_part_page.content_id],
        } },
      )

      second_take_part_page = build(:take_part_page)
      second_take_part_page.attributes = { title: "Second Page", ordering: 2 }
      second_take_part_page.save!

      assert_publishing_api_patch_links(
        get_involved_content_id,
        { links: {
          take_part_pages: [@take_part_page.content_id, second_take_part_page.content_id, third_take_part_page.content_id],
        } },
      )
    end
  end

  test "TakePartPage patches links in the correct order in the Get Involved Page when modified" do
    Sidekiq::Testing.inline! do
      # Working with a specific ID
      get_involved_content_id = "dbe329f1-359c-43f7-8944-580d4742aa91"

      # Build a couple Take Part pages with different ordering
      @take_part_page.attributes = { title: "First Page", ordering: 2 }
      @take_part_page.save!

      third_take_part_page = build(:take_part_page)
      third_take_part_page.attributes = { title: "Third Page", ordering: 3 }
      third_take_part_page.save!

      assert_publishing_api_patch_links(
        get_involved_content_id,
        { links: {
          take_part_pages: [@take_part_page.content_id, third_take_part_page.content_id],
        } },
      )

      # Easiest way to check a patch on edit is to change the ordering
      @take_part_page.attributes = { title: "First Page", ordering: 4 }
      @take_part_page.save!

      assert_publishing_api_patch_links(
        get_involved_content_id,
        { links: {
          take_part_pages: [third_take_part_page.content_id, @take_part_page.content_id],
        } },
      )
    end
  end

  test "TakePartPage patches links in the correct order in the Get Involved Page when deleted" do
    Sidekiq::Testing.inline! do
      # Working with a specific ID
      get_involved_content_id = "dbe329f1-359c-43f7-8944-580d4742aa91"

      # Build a couple Take Part pages with different ordering
      @take_part_page.attributes = { title: "First Page", ordering: 1 }
      @take_part_page.save!

      second_take_part_page = build(:take_part_page)
      second_take_part_page.attributes = { title: "Second Page", ordering: 2 }
      second_take_part_page.save!

      third_take_part_page = build(:take_part_page)
      third_take_part_page.attributes = { title: "Third Page", ordering: 3 }
      third_take_part_page.save!

      assert_publishing_api_patch_links(
        get_involved_content_id,
        { links: {
          take_part_pages: [@take_part_page.content_id, second_take_part_page.content_id, third_take_part_page.content_id],
        } },
      )

      # Destroy the middle item
      second_take_part_page.destroy!

      assert_publishing_api_patch_links(
        get_involved_content_id,
        { links: {
          take_part_pages: [@take_part_page.content_id, third_take_part_page.content_id],
        } },
      )
    end
  end
end
