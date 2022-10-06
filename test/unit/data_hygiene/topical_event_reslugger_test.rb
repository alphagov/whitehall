require "test_helper"
require "gds_api/test_helpers/search"

class TopicalEventResluggerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Search
  include FeedHelper

  setup do
    @old_slug = "old-slug"
    @new_slug = "new-slug"
    @topical_event = FactoryBot.create(:topical_event, slug: @old_slug)

    @detailed_guide = FactoryBot.create(:published_detailed_guide)
    @news_article = FactoryBot.create(:published_news_article)
    @topical_event.expects(:editions).returns([@detailed_guide, @news_article])

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

  test "reindexes the topical_event and all its linked editions" do
    [@topical_event, @detailed_guide, @news_article].each do |object|
      object.stubs(:remove_from_search_index)
      object.stubs(:update_in_search_index)

      object.expects(:remove_from_search_index)
      object.expects(:update_in_search_index)
    end

    @reslugger.run!
  end
end
