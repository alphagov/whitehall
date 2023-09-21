require "test_helper"
require "capybara/rails"

class ImageDeletionIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  describe "image deletion" do
    context "given a draft document with images" do
      context "images don't have assets" do
        let(:managing_editor) { create(:managing_editor) }
        let(:image) { build(:image) }
        let(:edition) { create(:news_article) }
        let(:versions) { %i[s960 s712 s630 s465 s300 s216] }

        before do
          login_as(managing_editor)
          stub_publishing_api_has_linkables([], document_type: "topic")
          edition.images << image
          setup_publishing_api_for(edition)
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

          stub_whitehall_asset(image.image_data.file.file.filename, id: image.image_data.file.file.asset_manager_path)
          versions.each { |version| stub_whitehall_asset(image.image_data.file.versions[version].file.filename, id: image.image_data.file.versions[version].file.asset_manager_path) }
          edition.save!
        end

        context "when image is deleted" do
          before do
            visit admin_news_article_path(edition)
            click_link "Modify images"
            click_link "Delete image"
            click_button "Delete image"
            assert_text "minister-of-funk.960x640.jpg has been deleted"
          end

          it "deletes the corresponding asset in Asset Manager" do
            Services.asset_manager.expects(:delete_asset).times(7).with(regexp_matches(/.*minister-of-funk.960x640.jpg.*/))
            assert_equal 7, AssetManagerDeleteAssetWorker.jobs.count

            AssetManagerDeleteAssetWorker.drain
          end
        end
      end

      context "images have assets" do
        let(:managing_editor) { create(:managing_editor) }
        let(:image) { build(:image_with_asset) }
        let(:first_asset_id) { image.image_data.assets.first.asset_manager_id }
        let(:edition) { create(:news_article) }

        before do
          login_as(managing_editor)
          stub_publishing_api_has_linkables([], document_type: "topic")
          edition.images << image
          setup_publishing_api_for(edition)
          stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

          image.image_data.assets.each { |asset| stub_asset(asset.asset_manager_id) }

          edition.save!
        end

        context "when one image is deleted" do
          before do
            visit admin_news_article_path(edition)
            click_link "Modify images"
            click_link "Delete image"
            click_button "Delete image"
            assert_text "minister-of-funk.960x640.jpg has been deleted"
          end

          it "deletes the corresponding asset in Assets and Assets Asset Manager" do
            Services.asset_manager.expects(:delete_asset).times(7).with(regexp_matches(/asset_manager_id.*/))

            AssetManagerDeleteAssetWorker.drain
          end
        end
      end
    end

  private

    def ends_with(expected)
      ->(actual) { actual.end_with?(expected) }
    end

    def setup_publishing_api_for(edition)
      stub_publishing_api_has_links({ content_id: edition.document.content_id, links: {} })
    end

    def stub_whitehall_asset(filename, attributes = {})
      url_id = "http://asset-manager/assets/#{attributes[:id]}"
      Services.asset_manager.stubs(:whitehall_asset)
              .with(&ends_with(filename))
              .returns(attributes.merge(id: url_id).stringify_keys)
    end

    def stub_asset(asset_manger_id, attributes = {})
      url_id = "http://asset-manager/assets/#{asset_manger_id}"
      Services.asset_manager.stubs(:asset)
              .with(asset_manger_id)
              .returns(attributes.merge(id: url_id).stringify_keys)
    end
  end
end
