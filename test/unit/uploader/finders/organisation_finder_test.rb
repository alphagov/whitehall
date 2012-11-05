require 'test_helper'

class Whitehall::Uploader::Finders::OrganisationFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns a single element array containing the organisation identified by name" do
    organisation = create(:organisation)
    assert_equal [organisation], Whitehall::Uploader::Finders::OrganisationFinder.find(organisation.name, @log, @line_number)
  end

  test "returns a single element array containing the organisation identified by slug" do
    organisation = create(:organisation)
    assert_equal [organisation], Whitehall::Uploader::Finders::OrganisationFinder.find(organisation.slug, @log, @line_number)
  end

  test "returns an empty array if the name is blank" do
    assert_equal [], Whitehall::Uploader::Finders::OrganisationFinder.find('', @log, @line_number)
  end

  test "doesn't log a warning if name is blank" do
    Whitehall::Uploader::Finders::OrganisationFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns an empty array if the organisation can't be found" do
    assert_equal [], Whitehall::Uploader::Finders::OrganisationFinder.find('made-up-organisation-name', @log, @line_number)
  end

  test "logs a warning if the organisation can't be found" do
    Whitehall::Uploader::Finders::OrganisationFinder.find('made-up-organisation-name', @log, @line_number)
    assert_match /Unable to find Organisation named 'made-up-organisation-name'/, @log_buffer.string
  end
end
