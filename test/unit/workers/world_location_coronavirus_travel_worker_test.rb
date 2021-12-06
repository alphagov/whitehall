require "test_helper"

class WorldLocationCoronavirusTravelWorkerTest < ActiveSupport::TestCase
  setup do
    @world_location = FactoryBot.create(
      :world_location,
      name: "France",
      news_page_content_id: "id-123",
      coronavirus_rag_status: "red",
      coronavirus_next_rag_status: "not red",
      coronavirus_next_rag_applies_at: Time.zone.tomorrow.noon,
    )
  end

  test "it updates the world location api" do
    WorldLocationCoronavirusTravelWorker.new.perform(@world_location.id)

    @world_location.reload
    assert_equal "not_red", @world_location.coronavirus_rag_status
    assert_nil @world_location.coronavirus_next_rag_status
    assert_nil @world_location.coronavirus_next_rag_applies_at
  end

  test "it enqueues a job" do
    assert_equal 0, WorldLocationCoronavirusTravelWorker.jobs.size

    WorldLocationCoronavirusTravelWorker.perform_at(
      @world_location.coronavirus_next_rag_applies_at,
      @world_location.id,
    )

    assert_equal 1, WorldLocationCoronavirusTravelWorker.jobs.size
  end
end
