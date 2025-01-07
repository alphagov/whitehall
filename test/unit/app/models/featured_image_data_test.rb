require "test_helper"

class FeaturedImageDataTest < ActiveSupport::TestCase
  test "rejects SVG logo uploads" do
    svg_image = File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))
    image_data = build(:featured_image_data, file: svg_image)

    assert_not image_data.valid?
    assert_includes image_data.errors.map(&:full_message), "File You are not allowed to upload \"svg\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "rejects non-image file uploads" do
    non_image_file = File.open(Rails.root.join("test/fixtures/folders.zip"))
    topical_event_featuring_image_data = build(:featured_image_data, file: non_image_file)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File You are not allowed to upload \"zip\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "should ensure that file is present" do
    topical_event_featuring_image_data = build(:featured_image_data, file: nil)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File cannot be blank"
  end

  test "accepts valid image uploads" do
    jpg_image = File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg"))
    topical_event_featuring_image_data = build(:featured_image_data, file: jpg_image)

    assert topical_event_featuring_image_data
    assert_empty topical_event_featuring_image_data.errors
  end

  test "should ensure the image size to be 960x640" do
    image = File.open(Rails.root.join("test/fixtures/images/50x33_gif.gif"))
    topical_event_featuring_image_data = build(:featured_image_data, file: image)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File is too small. Select an image that is 960 pixels wide and 640 pixels tall"
  end

  test "#all_asset_variants_uploaded? returns true if all assets present" do
    featured_image_data = build(:featured_image_data)

    assert featured_image_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns false if an asset variant is missing" do
    featured_image_data = build(:featured_image_data)
    featured_image_data.assets = []

    assert_not featured_image_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns true on update if the new assets have finished uploading" do
    featured_image_data = create(:featured_image_data)
    Sidekiq::Job.clear_all

    filename = "big-cheese.960x640.jpg"
    response = { "id" => "http://asset-manager/assets/asset-id", "name" => filename }
    Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{filename}/ }.returns(response)
    FeaturedImageUploader.versions.each_key do |version_prefix|
      Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{version_prefix}_#{filename}/ }.returns(response)
    end

    featured_image_data.update!(
      featured_image_data.attributes.merge(
        file: upload_fixture(filename),
      ),
    )

    AssetManagerCreateAssetWorker.drain

    featured_image_data.reload
    assert featured_image_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns false on update if the new assets have not finished uploading" do
    featured_image_data = create(:featured_image_data)

    featured_image_data.update!(
      featured_image_data.attributes.merge(
        file: upload_fixture("big-cheese.960x640.jpg", "image/jpg"),
      ),
    )

    assert_not featured_image_data.all_asset_variants_uploaded?
  end

  test "should not delete previous images when FeaturedImageData is updated" do
    featured_image_data = create(:featured_image_data)

    AssetManagerDeleteAssetWorker.expects(:perform_async).never

    featured_image_data.update!(file: upload_fixture("images/960x640_jpeg.jpg"))
  end

  test "should be invalid without a featured_imageable" do
    featured_image_data = build(:featured_image_data, featured_imageable: nil)

    assert_not featured_image_data.valid?
    assert_equal featured_image_data.errors.messages[:featured_imageable], ["cannot be blank"]
  end

  test "#republish_on_assets_ready should republish organisation and associations if assets are ready" do
    organisation = create(:organisation, :with_default_news_image)
    news_article = create(:news_article, :published, organisations: [organisation])
    create(:news_article, :draft, organisations: [organisation], document: news_article.document)

    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article.document).once

    organisation.default_news_image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish worldwide organisation and associations if assets are ready" do
    worldwide_organisation = create(:published_worldwide_organisation, :with_default_news_image)
    news_article = create(:news_article_world_news_story, :published, worldwide_organisations: [worldwide_organisation])
    draft_news_article = create(:news_article_world_news_story, :draft, worldwide_organisations: [worldwide_organisation])
    other_organisation_news_article = create(:news_article_world_news_story, :draft, worldwide_organisations: [create(:published_worldwide_organisation, :with_default_news_image)])
    news_article_with_image = create(:news_article_world_news_story, images: [create(:image)], worldwide_organisations: [worldwide_organisation])

    Whitehall::PublishingApi.expects(:republish_document_async).with(worldwide_organisation.document).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article.document).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(draft_news_article.document).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(other_organisation_news_article.document).never
    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article_with_image.document).never

    worldwide_organisation.default_news_image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish topical event if assets are ready" do
    topical_event = create(:topical_event, :with_logo)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once

    topical_event.logo.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish person and associations if assets are ready" do
    person = create(:person, :with_image)
    speech = create(:published_speech, role_appointment: create(:role_appointment, role: create(:ministerial_role), person:))
    create(:draft_speech, role_appointment: create(:role_appointment, role: create(:ministerial_role), person:), document: speech.document)
    create(:historical_account, person:)

    Whitehall::PublishingApi.expects(:republish_async).with(person).once
    Whitehall::PublishingApi.expects(:republish_async).with(person.historical_account).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(speech.document).once

    person.image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish take part page if assets are ready" do
    take_part_page = create(:take_part_page)

    Whitehall::PublishingApi.expects(:republish_async).with(take_part_page).once

    take_part_page.image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish feature via organisation if assets are ready" do
    speech1 = create(:speech)
    speech2 = create(:speech)
    document = create(:document, editions: [speech1, speech2])

    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document:, feature_list:)
    featurable = feature.feature_list.featurable

    Whitehall::PublishingApi.expects(:republish_async).with(featurable).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(document).once

    feature.image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should republish feature via world location news if assets are ready" do
    speech1 = create(:speech)
    speech2 = create(:speech)
    document = create(:document, editions: [speech1, speech2])

    world_location = create(:world_location)
    world_location_news = world_location.world_location_news
    feature_list = create(:feature_list, featurable: world_location_news, locale: :en)
    feature = create(:feature, document:, feature_list:)
    featurable = feature.feature_list.featurable

    Whitehall::PublishingApi.expects(:republish_async).with(featurable).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(document).once

    feature.image.republish_on_assets_ready
  end

  test "#republish_on_assets_ready should not run any republishing action if assets are not ready" do
    person = create(:person, :with_image)
    person.image.assets.destroy_all
    speech = create(:speech, role_appointment: create(:role_appointment, role: create(:ministerial_role), person:))
    create(:historical_account, person:)

    Whitehall::PublishingApi.expects(:republish_async).with(person).never
    Whitehall::PublishingApi.expects(:republish_async).with(person.historical_account).never
    Whitehall::PublishingApi.expects(:republish_document_async).with(speech.document).never

    person.image.republish_on_assets_ready
  end
end
