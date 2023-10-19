require "test_helper"

class CreateAssetRelationshipWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe CreateAssetRelationshipWorker do
    let(:worker) { CreateAssetRelationshipWorker.new }
    let(:expected_number_of_variants) { 1 }

    context "all assets can be retrieved from asset-manager" do
      before do
        stub_all_assets(assetables)
        stub_create_asset("asset_manager_id")

        Sidekiq.logger.expects(:info).times(6)

        @output = worker.perform(start_id, end_id)
        AssetManagerCreateAssetWorker.drain
        assetables.map(&:reload)
      end

      context "worker is run for a single assetable" do
        let(:assetable) { create(:organisation_with_logo) }
        let(:assetables) { [assetable] }
        let(:start_id) { assetable.id }
        let(:end_id) { assetable.id }

        it "generates assets for all logo variants" do
          assert_equal expected_number_of_variants, assetable.assets.count
          assert_equal true, assetable.all_asset_variants_uploaded?
        end

        it "increments counters" do
          assert_equal expected_number_of_variants, @output[:asset_counter]
          assert_equal 1, @output[:count]
        end
      end

      context "worker is run for an interval of assetables" do
        let(:first_assetable) { create(:organisation_with_logo) }
        let(:second_assetable) { create(:organisation_with_logo) }
        let(:assetables) { [first_assetable, second_assetable] }
        let(:start_id) { first_assetable.id }
        let(:end_id) { second_assetable.id }

        it "generates assets for all logo variants" do
          assert_equal expected_number_of_variants, first_assetable.assets.count
          assert_equal expected_number_of_variants, second_assetable.assets.count
        end

        it "increments counters" do
          assert_equal (expected_number_of_variants * 2), @output[:asset_counter]
          assert_equal 2, @output[:count]
        end
      end
    end

    context "assets cannot be found in asset manager" do
      let(:assetable) { create(:organisation_with_logo) }
      let(:start_id) { assetable.id }
      let(:end_id) { assetable.id }

      before do
        Services.asset_manager.stubs(:whitehall_asset).raises(GdsApi::HTTPNotFound, "Error message")
      end

      it "rescues HTTPNotFound error and logs if asset cannot be found at path" do
        Sidekiq.logger.expects(:info).times(6)
        Sidekiq.logger.expects(:warn).times(1).with(regexp_matches(/minister-of-funk.960x640.jpg/))

        worker.perform(start_id, end_id)
        assetable.reload

        assert_equal 0, assetable.assets.count
      end
    end

    context "skips organisations without a custom logo" do
      let(:assetable) { create(:organisation) }
      let(:start_id) { assetable.id }
      let(:end_id) { assetable.id }

      it "does not save any assets" do
        Sidekiq.logger.expects(:info).times(4)
        Sidekiq.logger.expects(:info).with("Created assets for 0 assetable").once
        Sidekiq.logger.expects(:info).with("Created asset counter 0").once

        worker.perform(start_id, end_id)
        assetable.reload

        assert_equal 0, assetable.assets.count
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
      stub_whitehall_asset(assetable.logo.file.filename, id: "asset_id_14652342")
    end
  end

  def stub_create_asset(asset_manger_id)
    url_id = "http://asset-manager/assets/#{asset_manger_id}"
    Services.asset_manager.stubs(:create_asset)
            .returns("id" => url_id, "name" => "filename.pdf")
  end
end
