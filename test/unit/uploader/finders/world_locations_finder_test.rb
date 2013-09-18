require 'test_helper'
require_relative '../importer_test_logger'

class Whitehall::Uploader::Finders::WorldLocationsFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
  end

  test "returns a single element array containing the world location identified by slug" do
    world_location = create(:world_location)
    assert_equal [world_location], Whitehall::Uploader::Finders::WorldLocationsFinder.find(world_location.slug, @log, @line_number)
  end

  test "returns an array of countries" do
    world_location_1 = create(:world_location)
    world_location_2 = create(:world_location)
    world_location_3 = create(:international_delegation)
    assert_equal [world_location_1, world_location_2, world_location_3], Whitehall::Uploader::Finders::WorldLocationsFinder.find(world_location_1.slug, world_location_2.slug, world_location_3.slug, @log, @line_number)
  end

  test "returns an empty array if the slugs are blank" do
    assert_equal [], Whitehall::Uploader::Finders::WorldLocationsFinder.find('', @log, @line_number)
  end

  test "doesn't log a warning if slug is blank" do
    Whitehall::Uploader::Finders::WorldLocationsFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns an empty array if the world location can't be found" do
    assert_equal [], Whitehall::Uploader::Finders::WorldLocationsFinder.find('made-up-world-location-name', @log, @line_number)
  end

  test "logs a warning if the world location can't be found" do
    Whitehall::Uploader::Finders::WorldLocationsFinder.find('made-up-world-location-name', @log, @line_number)
    assert_match /Unable to find WorldLocation with slug 'made-up-world-location-name'/, @log_buffer.string
  end
end
