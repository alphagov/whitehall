require "test_helper"

class CreateAssetRelationshipWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe CreateAssetRelationshipWorker do
    let(:worker) { CreateAssetRelationshipWorker.new }
    let(:assetable_type) { "ImageData" }

    context "all assets can be retrieved from asset-manager" do
      before do
        stub_all_assets(assetables)

        @output = worker.perform(assetable_type, start_id, end_id)
        AssetManagerCreateAssetWorker.drain
        assetables.map(&:reload)
      end

      context "worker is run for a single assetable" do
        let(:assetable) { create(:image_data) }
        let(:assetables) { [assetable] }
        let(:start_id) { assetable.id }
        let(:end_id) { assetable.id }

        it "generates assets for all image variants" do
          assert_equal 7, assetable.assets.count
          assert_equal true, assetable.use_non_legacy_endpoints
          assert_equal true, assetable.all_asset_variants_uploaded?
        end

        it "increments counters" do
          assert_equal 7, @output[:asset_counter]
          assert_equal 1, @output[:count]
        end
      end

      context "worker is run for an svg assetable" do
        let(:assetable) { create(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))) }
        let(:assetables) { [assetable] }
        let(:start_id) { assetable.id }
        let(:end_id) { assetable.id }

        it "generates assets for only original variant" do
          assert_equal 1, assetable.assets.count
          assert_equal true, assetable.use_non_legacy_endpoints
          assert_equal true, assetable.all_asset_variants_uploaded?
        end

        it "increments counters" do
          assert_equal 1, @output[:asset_counter]
          assert_equal 1, @output[:count]
        end
      end

      context "worker is run for an interval of assetables" do
        let(:first_assetable) { create(:image_data) }
        let(:second_assetable) { create(:image_data) }
        let(:assetables) { [first_assetable, second_assetable] }
        let(:start_id) { first_assetable.id }
        let(:end_id) { second_assetable.id }

        it "generates assets for all image variants" do
          assert_equal 7, first_assetable.assets.count
          assert_equal 7, second_assetable.assets.count
          assert_equal true, first_assetable.use_non_legacy_endpoints
          assert_equal true, second_assetable.use_non_legacy_endpoints
        end

        it "increments counters" do
          assert_equal 14, @output[:asset_counter]
          assert_equal 2, @output[:count]
        end
      end
    end

    context "assets cannot be found in asset manager" do
      let(:assetable) { create(:image_data) }
      let(:start_id) { assetable.id }
      let(:end_id) { assetable.id }

      before do
        Services.asset_manager.stubs(:whitehall_asset).raises(GdsApi::HTTPNotFound, "Error message")
      end

      it "rescues HTTPNotFound error and logs if asset cannot be found at path" do
        Sidekiq.logger.expects(:warn).times(7).with(regexp_matches(/minister-of-funk.960x640.jpg/))

        worker.perform(assetable_type, start_id, end_id)
        assetable.reload

        assert_equal 0, assetable.assets.count
        assert_equal true, assetable.use_non_legacy_endpoints
      end
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

  def stub_all_assets(assetables)
    assetables.each do |assetable|
      stub_whitehall_asset(assetable.file.file.filename, id: "asset_id_14652342")
    end
  end
end
