require "test_helper"

class PromotionalFeatureItemTest < ActiveSupport::TestCase
  VALID_YOUTUBE_URLS = [
    "https://youtu.be/fFmDQn9Lbl4",
    "https://www.youtube.com/watch?v=fFmDQn9Lbl4",
  ].freeze

  test "invalid without a summary" do
    assert_not build(:promotional_feature_item, summary: nil).valid?
  end

  test "limits summary to a maximum of 500 characters" do
    assert build(:promotional_feature_item, summary: string_of_length(500)).valid?

    item = build(:promotional_feature_item, summary: string_of_length(501))
    assert_not item.valid?
    assert_equal ["is too long (maximum is 500 characters)"], item.errors[:summary]
  end

  test "validates the title url is valid if supplied" do
    item = build(:promotional_feature_item, title_url: "ftp://invalid.com")
    assert_not item.valid?
    assert_equal ["is not valid. Make sure it starts with http(s)"], item.errors[:title_url]
  end

  test "accepts nested attributes for links" do
    item = create(:promotional_feature_item, links_attributes: [{ url: "http://example.com", text: "Example link" }])
    assert_equal 1, item.links.count
    assert_equal "http://example.com", item.links.first.url
    assert_equal "Example link", item.links.first.text
  end

  test "validates that an image or youtube_video_url is present on save" do
    feature_item_with_image = build(:promotional_feature_item)
    feature_item_with_youtube_url = build(:promotional_feature_item_with_youtube_video_url)
    invalid_feature_item = build(:promotional_feature_item, image: nil, youtube_video_url: nil)

    assert feature_item_with_image.valid?
    assert feature_item_with_youtube_url.valid?
    assert_not invalid_feature_item.valid?
    assert_equal invalid_feature_item.errors.full_messages, ["Image or youtube url Upload either an image or add a YouTube URL"]
  end

  test "validates that either an image and youtube_video_url can be provided" do
    invalid_feature_item = build(:promotional_feature_item, youtube_video_url: "https://www.youtube.com/watch?v=fFmDQn9Lbl4", youtube_video_alt_text: "Alt text.")

    assert_not invalid_feature_item.valid?
    assert_equal invalid_feature_item.errors.full_messages, ["Image or youtube url Upload either an image or add a YouTube URL"]
  end

  VALID_YOUTUBE_URLS.each do |url|
    test "validates that a youtube_video_url of `#{url}` is valid" do
      assert build(:promotional_feature_item_with_youtube_video_url, youtube_video_url: url).valid?
    end
  end

  test "validates that a youtube_video_url of `https://www.gov.uk/government/organisations/government-digital-service` is invalid" do
    promotional_feature_item = build(:promotional_feature_item_with_youtube_video_url, youtube_video_url: "https://www.gov.uk/government/organisations/government-digital-service")

    assert_not promotional_feature_item.valid?
    assert_equal promotional_feature_item.errors[:youtube_video_url], ["Did not match expected format, please use a https://www.youtube.com/watch?v=MSmotCRFFMc or https://youtu.be/MSmotCRFFMc URL"]
  end

  VALID_YOUTUBE_URLS.each do |url|
    test "#youtube_video_id returns the youtube_video_id for `#{url}`" do
      assert_equal build(:promotional_feature_item_with_youtube_video_url, youtube_video_url: url).youtube_video_id, "fFmDQn9Lbl4"
    end
  end

  test "#youtube_video_id raises an exception when an youtube_video_id cannot be parsed form the youtube_video_url" do
    promotional_feature_item = build(:promotional_feature_item_with_youtube_video_url, youtube_video_url: "https://www.gov.uk/government/organisations/government-digital-service")

    assert_raises StandardError, match: "youtube_video_url: #{promotional_feature_item.youtube_video_url} is invalid for PromotionalFeatureItem id: #{promotional_feature_item.id}" do
      promotional_feature_item.youtube_video_id
    end
  end

  test "rejects SVG logo uploads" do
    svg_image = File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))
    promotional_feature = build(:promotional_feature_item, image: svg_image)

    assert_not promotional_feature.valid?
    assert_includes promotional_feature.errors.map(&:full_message), "Image You are not allowed to upload \"svg\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "rejects non-image file uploads" do
    non_image_file = File.open(Rails.root.join("test/fixtures/folders.zip"))
    promotional_feature_item = build(:promotional_feature_item, image: non_image_file)

    assert_not promotional_feature_item.valid?
    assert_includes promotional_feature_item.errors.map(&:full_message), "Image You are not allowed to upload \"zip\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "accepts valid image uploads" do
    jpg_image = File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg"))
    promotional_feature_item = build(:promotional_feature_item, image: jpg_image)

    assert promotional_feature_item
    assert_empty promotional_feature_item.errors
  end

  test "#republish_on_assets_ready should republish associated organisation if image assets are ready" do
    promotional_feature_item = create(:promotional_feature_item)

    Whitehall::PublishingApi.expects(:republish_async).with(promotional_feature_item.organisation).once

    promotional_feature_item.republish_on_assets_ready
  end

  test "should republish organisation on save" do
    promotional_feature_item = create(:promotional_feature_item)
    organisation = promotional_feature_item.organisation

    organisation.expects(:republish_to_publishing_api_async)

    promotional_feature_item.save!
  end

  test "should republish organisation on destroy" do
    promotional_feature_item = create(:promotional_feature_item)
    organisation = promotional_feature_item.organisation

    organisation.expects(:republish_to_publishing_api_async)

    promotional_feature_item.destroy!
  end

  test "#all_asset_variants_uploaded? returns true on update if the new assets have finished uploading" do
    promotional_feature_item = create(:promotional_feature_item)
    Sidekiq::Worker.clear_all

    filename = "big-cheese.960x640.jpg"
    response = { "id" => "http://asset-manager/assets/asset-id", "name" => filename }
    Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{filename}/ }.returns(response)
    FeaturedImageUploader.versions.each_key do |version_prefix|
      Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{version_prefix}_#{filename}/ }.returns(response)
    end

    promotional_feature_item.update!(
      promotional_feature_item.attributes.merge(
        image: upload_fixture(filename, "image/jpg"),
      ),
    )

    AssetManagerCreateAssetWorker.drain

    promotional_feature_item.reload
    assert promotional_feature_item.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns false on update if the new assets have not finished uploading" do
    promotional_feature_item = create(:promotional_feature_item)

    promotional_feature_item.update!(
      promotional_feature_item.attributes.merge(
        image: upload_fixture("big-cheese.960x640.jpg", "image/jpg"),
      ),
    )

    assert_not promotional_feature_item.all_asset_variants_uploaded?
  end

private

  def string_of_length(length)
    "X" * length
  end
end
