require "test_helper"

class TopicalEventResluggerTest < ActiveSupport::TestCase
  setup do
    @old_slug = "old-slug"
    @new_slug = "new-slug"
    @topical_event = FactoryBot.create(:topical_event, slug: @old_slug)

    @detailed_guide = FactoryBot.create(:published_detailed_guide)
    @topical_event.expects(:editions).returns([@detailed_guide])

    @reslugger = DataHygiene::TopicalEventReslugger.new(@topical_event, @new_slug)
  end

  test "updates the topical_event's slug" do
    assert_changes -> { @topical_event.slug }, from: @old_slug, to: @new_slug do
      @reslugger.run!
    end
  end

  test "republishes the topical_event to Publishing API" do
    Whitehall::PublishingApi.expects(:republish_async).with(@topical_event)

    @reslugger.run!
  end
end
