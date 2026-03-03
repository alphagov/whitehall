require "test_helper"

class PublishingApiDraftUpdateJobTest < ActiveSupport::TestCase
  test "should perform a draft update of an edition to publishing api" do
    consultation = FactoryBot.create(:consultation)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(consultation)

    PublishingApiDraftUpdateJob.new.perform(consultation.class.name, consultation.id)
  end
end
