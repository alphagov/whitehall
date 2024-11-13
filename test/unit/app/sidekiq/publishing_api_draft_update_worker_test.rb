require "test_helper"

class PublishingApiDraftUpdateWorkerTest < ActiveSupport::TestCase
  test "should perform a draft update of an edition to publishing api" do
    consultation = FactoryBot.create(:consultation)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(consultation)

    PublishingApiDraftUpdateWorker.new.perform(consultation.class.name, consultation.id)
  end
end
