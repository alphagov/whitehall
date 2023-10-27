require "test_helper"

class CreateAssetRelationshipForFeaturedImageDataWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe CreateAssetRelationshipForFeaturedImageDataWorker do
    before do
      @worker = CreateAssetRelationshipForFeaturedImageDataWorker.new
    end

    it("should not run migration if start_id is greater than end_id") do
      Organisation.expects(:find).with(anything).never
      @worker.perform(2, 1)
    end

    it("creates featured_image_data_id if default_news_organisation_image_data is present") do
      Sidekiq.logger.expects(:info).times(3)
      default_news_image_data = build(:default_news_organisation_image_data)
      organisation = create(:organisation, default_news_image: default_news_image_data)
      assert_nil organisation.default_news_image_new
      @worker.perform(organisation.id, organisation.id)
      organisation.reload
      assert_not_nil organisation.default_news_image_new
    end

    it("does not creates featured_image_data_id if default_news_organisation_image_data is not present") do
      Sidekiq.logger.expects(:info).times(2)
      organisation = create(:organisation)
      assert_nil organisation.default_news_image_new
      @worker.perform(organisation.id, organisation.id)
      organisation.reload
      assert_nil organisation.default_news_image_new
    end

    it("maps correct carrierwave_image to featured_image_data_id") do
      Sidekiq.logger.expects(:info).times(3)
      default_news_image_data = build(:default_news_organisation_image_data)
      organisation = create(:organisation, default_news_image: default_news_image_data)
      @worker.perform(organisation.id, organisation.id)
      organisation.reload
      assert_equal organisation.default_news_image_new.carrierwave_image, organisation.default_news_image.carrierwave_image
    end
  end
end
