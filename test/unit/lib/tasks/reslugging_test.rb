require "test_helper"
require "rake"

class ResluggingTest < ActiveSupport::TestCase
  teardown do
    Sidekiq::Worker.clear_all
  end

  test "it should reslug the world location" do
    world_location_news = build(:world_location_news, content_id: SecureRandom.uuid)
    world_location = create(:world_location, slug: "old-name", world_location_news:)
    Rake.application.invoke_task "reslug:world_location[old-name,new-name]"

    assert_equal "new-name", world_location.reload.slug
  end
end
