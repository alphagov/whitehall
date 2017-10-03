require "test_helper"

class WorldLocationNewsPageWorkerTest < ActiveSupport::TestCase
  setup do
    Services.publishing_api.stubs(:lookup_content_ids).returns(Hash.new("id-123"))

    @world_location = FactoryGirl.create(:world_location)
    @presenter = PublishingApi::WorldLocationNewsPagePresenter.new(@world_location)
  end

  test "sends to the publishing api" do
    Services.publishing_api.expects(:put_content).with("id-123", @presenter.content)
    Services.publishing_api.expects(:publish).with("id-123", nil, locale: "en")

    WorldLocationNewsPageWorker.new.perform(@world_location.id)
  end

  test "sends to rummager" do
    Whitehall::FakeRummageableIndex.any_instance.expects(:add)
      .with(@presenter.content_for_rummager)

    WorldLocationNewsPageWorker.new.perform(@world_location.id)
  end
end
