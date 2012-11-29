require 'test_helper'

class Whitehall::Uploader::Finders::CountriesFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns a single element array containing the country identified by name" do
    country = create(:country)
    assert_equal [country], Whitehall::Uploader::Finders::CountriesFinder.find(country.slug, @log, @line_number)
  end

  test "returns an empty array if the slugs are blank" do
    assert_equal [], Whitehall::Uploader::Finders::CountriesFinder.find('', @log, @line_number)
  end

  test "doesn't log a warning if name is blank" do
    Whitehall::Uploader::Finders::CountriesFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns an empty array if the country can't be found" do
    assert_equal [], Whitehall::Uploader::Finders::CountriesFinder.find('made-up-country-name', @log, @line_number)
  end

  test "logs a warning if the organisation can't be found" do
    Whitehall::Uploader::Finders::CountriesFinder.find('made-up-country-name', @log, @line_number)
    assert_match /Unable to find Country with slug 'made-up-country-name'/, @log_buffer.string
  end
end
