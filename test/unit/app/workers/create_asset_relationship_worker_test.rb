require "test_helper"

class CreateAssetRelationshipWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  before do
    @worker  = CreateAssetRelationshipWorker.new
    variants = %i[original s960 s712 s630 s465 s300 s216]
    @default_news_image_data = create(:default_news_organisation_image_data)
    @featured_image_data = create(:featured_image_data)
    @featured_image_data.assets.destroy_all
    variants.each do |variant|
      stub_assets(variant, @default_news_image_data)
    end
  end

  it("should save correctly assets with FeaturedImageData when asset_manager.whitehall_asset is fetched for DefaultNewsOrganisationImageData ") do
    Sidekiq.logger.expects(:info).times(6)
    organisation = build_organisation_with_default_and_featured_image

    @worker.perform(0, organisation.id)
    assert_equal 7, Asset.where(assetable_type: "FeaturedImageData", assetable_id: organisation.default_news_image_new.id).count
  end

  it("should skip Organisation if default_news_organisation_image_data is nil") do
    Sidekiq.logger.expects(:info).times(6)

    build_organisation_with_default_and_featured_image
    organisation_without_image = create(:organisation)

    output = @worker.perform(0, organisation_without_image.id)

    assert_equal 7, output[:asset_counter]
    assert_equal 1, output[:assetables_count]
  end

  it("should log warning if asset is not found in asset manager") do
    Sidekiq.logger.expects(:info).times(6)
    Sidekiq.logger.expects(:warn).times(7).with(regexp_matches(/big-cheese.960x640.jpg/))

    default_news_image_data = create(:default_news_organisation_image_data, file: File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg")))
    create(:organisation, default_news_image: default_news_image_data, default_news_image_new: @featured_image_data)
    organisation_with_image = build_organisation_with_default_and_featured_image

    Services.asset_manager.stubs(:whitehall_asset).with(&ends_with("big-cheese.960x640.jpg")).raises(GdsApi::HTTPNotFound, "Error message")

    output = @worker.perform(0, organisation_with_image.id)
    assert_equal 7, output[:asset_counter]
    assert_equal 2, output[:assetables_count]
  end
end

  private

def ends_with(expected)
  ->(actual) { actual.end_with?(expected) }
end

def stub_whitehall_asset(filename, attributes = {})
  url_id = "http://asset-manager/assets/#{attributes[:id]}"
  Services.asset_manager.stubs(:whitehall_asset)
          .with(&ends_with(filename))
          .returns(attributes.merge(id: url_id, name: filename).stringify_keys)
end

def stub_assets(variant, default_news_image_data)
  if variant == :original
    stub_whitehall_asset(default_news_image_data.file.identifier.to_s, id: "asset_id")
  else
    stub_whitehall_asset("#{variant}_#{default_news_image_data.file.versions[variant].identifier}", id: "#{variant}_asset_id")
  end
end

def build_organisation_with_default_and_featured_image
  create(:organisation, default_news_image: @default_news_image_data, default_news_image_new: @featured_image_data)
end
